terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
  backend "s3" {
    key = "observability.tfstate"
  }
}
provider "helm" {
  kubernetes {
    config_path = "${path.module}/../bootstrap/.out/k8s-project-kubeconfig"
  }
}