resource "selectel_vpc_project_v2" "project_otus" {
  name = "${var.project_name}-${var.project_stage}"
}
resource "selectel_iam_serviceuser_v1" "project_otus" {
  name         = local.project_user
  password     = local.project_password
  role {
    role_name  = "member"
    scope      = "project"
    project_id = selectel_vpc_project_v2.project_otus.id
  }
}
resource "selectel_vpc_keypair_v2" "otus_project_sshkey" {
  name       = "${var.project_name}-${var.project_stage}-key"
  public_key = tls_private_key.project_ssh_key.public_key_openssh
  user_id    = selectel_iam_serviceuser_v1.project_otus.id
}
