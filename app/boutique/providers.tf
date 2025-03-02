terraform {
  required_providers {
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
    key = "boutique.tfstate"
  }
}
provider "helm" {
  kubernetes {
    config_path = "${path.module}/../../infra/bootstrap/.out/k8s-project-kubeconfig"
  }
}
provider "kubectl" {
  config_path = "${path.module}/../../infra/bootstrap/.out/k8s-project-kubeconfig"
}
