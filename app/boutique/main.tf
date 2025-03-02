resource "helm_release" "boutique" {
  repository       = "oci://us-docker.pkg.dev/online-boutique-ci/charts"
  chart            = "onlineboutique"

  name             = "onlineboutique"
  namespace        = "boutique"
  create_namespace = true
  wait             = true
  wait_for_jobs    = true
}