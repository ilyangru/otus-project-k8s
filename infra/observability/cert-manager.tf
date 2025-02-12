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

resource "kubectl_manifest" "cert_manager_clusterissuer" {
  depends_on = [ helm_release.cert_manager ]
  yaml_body = file("${path.module}/templates/cert-manager-cluster-issuer.yaml")
  wait = true
}
