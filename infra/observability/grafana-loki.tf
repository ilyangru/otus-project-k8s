data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    endpoints = { s3 = "https://${var.bootstrap_state_s3_url}" }
    key = var.bootstrap_state_s3_key
    region = "ru-1"
    skip_region_validation = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_s3_checksum = true
    skip_metadata_api_check = true
    bucket = var.bootstrap_state_s3_bucket
    access_key=var.bootstrap_state_s3_access_key
    secret_key=var.bootstrap_state_s3_secret_key
  }
}
resource "random_string" "loki_bucket_suffix" {
  length = 8
  special = false
  upper = false
}
resource "random_password" "selectel_loki_sa_password" {
  length = 32
  special = false
  min_upper = 5
  min_lower = 5
  min_numeric = 5
}
resource "selectel_iam_serviceuser_v1" "loki" {
  name = "loki-${random_string.loki_bucket_suffix.result}"
  password     = random_password.selectel_loki_sa_password.result
  role {
    role_name  = "object_storage:admin" #"object_storage_user"
    scope      = "project"
    project_id = data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id
  }
}
resource "selectel_iam_s3_credentials_v1" "loki" {
  user_id    = selectel_iam_serviceuser_v1.loki.id
  project_id = data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id
  name       = "loki-s3-${random_string.loki_bucket_suffix.result}"
}
resource "openstack_objectstorage_container_v1" "loki_data" {
  name = "loki-data-${random_string.loki_bucket_suffix.result}"
  region = "ru-1"
  content_type  = "application/json"
  force_destroy = true
  # container_read = "*:*" #"${data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id}:${selectel_iam_serviceuser_v1.loki.id}"
  # container_write = "*:*" #"${data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id}:${selectel_iam_serviceuser_v1.loki.id}"
}
resource "openstack_objectstorage_container_v1" "loki_ruler" {
  name = "loki-ruler-${random_string.loki_bucket_suffix.result}"
  region = "ru-1"
  content_type  = "application/json"
  force_destroy = true
  # container_read = "*:*" #"${data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id}:${selectel_iam_serviceuser_v1.loki.id}"
  # container_write = "*:*" #"${data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id}:${selectel_iam_serviceuser_v1.loki.id}"
}
resource "openstack_objectstorage_container_v1" "loki_admin" {
  name = "loki-admin-${random_string.loki_bucket_suffix.result}"
  region = "ru-1"
  content_type  = "application/json"
  force_destroy = true
  # container_read = "*:*" #"${data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id}:${selectel_iam_serviceuser_v1.loki.id}"
  # container_write = "*:*" #"${data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id}:${selectel_iam_serviceuser_v1.loki.id}"
}

resource "helm_release" "loki" {
  depends_on = [
    kubectl_manifest.cert_manager_clusterissuer,
    helm_release.ingress_nginx
  ]
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"

  name             = "loki"
  #namespace        = "prometheus-operator"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
  values = [
    templatefile("${path.module}/templates/loki-values.yaml.tftpl",
      {
        s3_endpoint_url = var.bootstrap_state_s3_url
        s3_region = "ru-1"
        s3_access_key = selectel_iam_s3_credentials_v1.loki.access_key
        s3_secret_key = selectel_iam_s3_credentials_v1.loki.secret_key
        s3_bucket_loki_data = openstack_objectstorage_container_v1.loki_data.name
        s3_bucket_loki_ruler = openstack_objectstorage_container_v1.loki_ruler.name
        s3_bucket_loki_admin = openstack_objectstorage_container_v1.loki_admin.name
      }
    )
  ]
}
resource "helm_release" "promtail" {
  depends_on = [
    helm_release.loki
  ]
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"

  name             = "promtail"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
  values = [
    file("${path.module}/templates/promtail-values.yaml")
  ]
}