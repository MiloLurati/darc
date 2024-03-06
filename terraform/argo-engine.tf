resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "helm_release" "argo_workflows" {
  depends_on = [module.eks, module.vpc, kubernetes_namespace.argo]

  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = "0.40.14"
  namespace  = "argo"
}