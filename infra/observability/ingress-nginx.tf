resource "helm_release" "ingress_nginx" {
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
}

