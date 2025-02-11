resource "random_password" "grafana_admin_password" {
  length = 16
  special = false
  min_upper = 3
  min_lower = 3
  min_numeric = 3
}

locals {
  grafana_admin_password = can(var.grafana_admin_password) ? var.grafana_admin_password : random_password.grafana_admin_password.result
  prometheus_affinity_key = "worker-group"
  prometheus_affinity_value = "monitoring"
}

resource "helm_release" "cert_manager" {
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = can(var.cert_manager_version) ? var.cert_manager_version : "latest"

  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "prometheus" {
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"

  name             = "prometheus"
  namespace        = "prometheus-operator"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml.tftpl",
      {
        grafana_admin_password = local.grafana_admin_password
        affinity_key = local.prometheus_affinity_key
        affinity_value = local.prometheus_affinity_value
      }
    )
  ]
}
output "values_yaml" {
  value = templatefile("${path.module}/templates/prometheus-values.yaml.tftpl",
      {
        grafana_admin_password = local.grafana_admin_password
        affinity_key = local.prometheus_affinity_key
        affinity_value = local.prometheus_affinity_value
      }
    )
  sensitive = true
}