variable "cert_manager_version" {
  type = string
  default = ""
}
variable "grafana_admin_password" {
  type = string
  sensitive = true
  default = ""
}