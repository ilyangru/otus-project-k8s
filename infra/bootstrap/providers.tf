terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }
    selectel = {
      source  = "selectel/selectel"
      version = "6.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
  backend "s3" {}
}
provider "selectel" {
  auth_url    = var.sel_auth_url
  domain_name = var.sel_account_id
  username    = var.sel_admin_user
  password    = var.sel_admin_password
  auth_region = var.sel_project_region # "pool" ?
}
provider "openstack" {
  auth_url    = var.sel_auth_url
  tenant_id   = selectel_vpc_project_v2.project_otus.id
  domain_name = var.sel_account_id
  user_name   = selectel_iam_serviceuser_v1.project_otus.name
  password    = selectel_iam_serviceuser_v1.project_otus.password
  region      = var.sel_project_region
}