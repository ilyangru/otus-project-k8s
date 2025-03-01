# common Selectel account variables
variable "sel_auth_url" {
  type = string
  default = "https://cloud.api.selcloud.ru/identity/v3"
}
variable "sel_account_id" {
  # openstack domain name
  # цифровой код аккаунта Селектел
  type = string
}
variable "sel_admin_user" {
  # openstack admin service user name
  type = string
}
variable "sel_admin_password" {
  # openstack admin service user password
  type = string
  sensitive = true
}

# Project variables
variable "sel_project_region" {
  # openstack region
  type = string
  default = "ru-2"
}
variable "project_name" {
  type = string
  default = "k8s"
}
variable "project_stage" {
  type = string
  default = "project"
}

variable "cert_manager_version" {
  type = string
  default = ""
}
variable "grafana_admin_password" {
  type = string
  sensitive = true
  default = ""
}
variable "bootstrap_state_s3_url" {}
variable "bootstrap_state_s3_key" {}
variable "bootstrap_state_s3_bucket" {}
variable "bootstrap_state_s3_access_key" {
  sensitive = true
}
variable "bootstrap_state_s3_secret_key" {
  sensitive = true
}
