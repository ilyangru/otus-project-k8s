terraform {
  required_providers {
    # terraform = {
    #   source  = "builtin/terraform"
    #   #version = ""
    # }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }
    selectel = {
      source  = "selectel/selectel"
      version = "6.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  backend "s3" {
    key = "observability.tfstate"
  }
}
provider "selectel" {
  auth_url    = var.sel_auth_url
  domain_name = var.sel_account_id
  username    = var.sel_admin_user
  password    = var.sel_admin_password
  auth_region = var.sel_project_region
}
provider "openstack" {
  auth_url    = var.sel_auth_url
  tenant_id   = data.terraform_remote_state.bootstrap.outputs.otus_project.tenant_id #selectel_vpc_project_v2.project_otus.id
  domain_name = var.sel_account_id
  user_name   = data.terraform_remote_state.bootstrap.outputs.otus_project.user_name
  password    = data.terraform_remote_state.bootstrap.outputs.otus_project.password
  region      = var.sel_project_region
}
provider "helm" {
  kubernetes {
    config_path = "${path.module}/../bootstrap/.out/k8s-project-kubeconfig"
  }
}
provider "kubectl" {
  config_path = "${path.module}/../bootstrap/.out/k8s-project-kubeconfig"
}
