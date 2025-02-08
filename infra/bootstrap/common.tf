locals {
  project = "${var.project_name}-${var.project_stage}"
  project_user = "serviceaccount-${random_string.project_otus_user_suffix.result}"
  project_password = random_password.project_otus_password.result
  system_node_list = flatten([
    for cur_name, cur_group in var.system_node_group : [
      for cur_idx in range(1, cur_group.count+1) : {
        name : "${var.project_name}-${var.project_stage}-${cur_name}-${cur_idx}"
        group : cur_name
      }
    ]
  ])
  static_worker_node_list = flatten([
    for cur_name, cur_group in var.static_worker_node_group : [
      for cur_idx in range(1, cur_group.count+1) : {
        name : "${var.project_name}-${var.project_stage}-${cur_name}-${cur_idx}"
        group : cur_name
        labels: { for cur_label in var.static_worker_node_group[cur_name].labels: split("=",cur_label)[0] => split("=",cur_label)[1] if length(split("=",cur_label))==2 }
      }
    ]
  ])
  # static_worker_labels = {
  #   for cur_worker in static_worker_node_list: cur_worker.name => cur_worker.group
  # }
  bastion_user = "root"
  ssh_username = "root"
}
resource "tls_private_key" "project_ssh_key" {
  algorithm = "ED25519"
}
resource "random_string" "project_otus_user_suffix" {
  length = 6
  special = false
  upper = false
  min_lower   = 2
  min_numeric = 2
}
resource "random_password" "project_otus_password" {
  length = 32
  special = false
  min_upper = 4
  min_lower = 4
  min_numeric = 4
}
resource "random_string" "flavor_suffix" {
  length = 6
  special = false
  upper = false
  min_lower   = 2
  min_numeric = 2
}
resource "local_sensitive_file" "sshkey" {
  filename = "${path.module}/.out/id-${var.project_name}"
  content = tls_private_key.project_ssh_key.private_key_openssh
  directory_permission = "0700"
  file_permission = "0600"
}
resource "local_sensitive_file" "sshkeypub" {
  filename = "${path.module}/.out/id-${var.project_name}.pub"
  content = tls_private_key.project_ssh_key.public_key_openssh
  file_permission = "0600"
  directory_permission = "0700"
}
resource "local_sensitive_file" "kubeone_yaml" {
  filename = "${path.module}/.out/kubeone.yaml"
  file_permission = "0600"
  directory_permission = "0700"
  content = templatefile( "${path.module}/templates/kubeone.yaml.tftpl",
            {
              auth_url = var.sel_auth_url,
              tenant_id = selectel_vpc_project_v2.project_otus.id,
              domain_id = var.sel_account_id,
              username = selectel_iam_serviceuser_v1.project_otus.name,
              password = selectel_iam_serviceuser_v1.project_otus.password,
              subnet_id = openstack_networking_subnet_v2.project_private_subnet.id,
              region = var.sel_project_region
            }
  )
}
resource "local_sensitive_file" "env" {
  filename = "${path.module}/.out/.env"
  file_permission = "0600"
  directory_permission = "0700"
  content = templatefile( "${path.module}/templates/env.tftpl",
            {
              auth_url = var.sel_auth_url,
              tenant_id = selectel_vpc_project_v2.project_otus.id,
              domain_id = var.sel_account_id,
              username = selectel_iam_serviceuser_v1.project_otus.name,
              password = selectel_iam_serviceuser_v1.project_otus.password,
              subnet_id = openstack_networking_subnet_v2.project_private_subnet.id,
              regoin_name = var.sel_project_region
            }
  )
}
