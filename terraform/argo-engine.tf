# resource "kubernetes_namespace" "argo" {
#   metadata {
#     name = "argo"
#   }
#   depends_on = [ module.eks ]
# }

# resource "kubernetes_service_account" "argo_sa" {
#   metadata {
#     name      = "argo-sa"
#     namespace = kubernetes_namespace.argo.metadata[0].name
#   }
# }

# resource "kubernetes_cluster_role" "argo_cr" {
#   metadata {
#     name      = "argo-role"
#   }

#   rule {
#     api_groups = [""]
#     verbs      = ["get", "watch", "patch", "delete"]
#     resources  = ["pods", "pods/log", "pods/exec"]
#   }

#   rule {
#     api_groups = ["argoproj.io"]
#     verbs      = ["list", "watch", "create", "get", "update", "delete", "patch"]
#     resources  = ["workflowtasksets", "workflowartifactgctasks", "workflowtemplates", "workflows", "cronworkflows", "workflowtasksets/status", "workflowartifactgctasks/status", "workflows/status"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "argo_crb" {
#   metadata {
#     name = "argo-crb"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.argo_cr.metadata[0].name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.argo_sa.metadata[0].name
#     namespace = kubernetes_service_account.argo_sa.metadata[0].namespace
#   }
# }

# resource "kubernetes_secret" "argo_token" {
#   metadata {
#     name        = "argo.service-account-token"
#     namespace   = kubernetes_namespace.argo.metadata[0].name
#     annotations = {
#       "kubernetes.io/service-account.name" = kubernetes_service_account.argo_sa.metadata[0].name
#     }
#   }

#   type = "kubernetes.io/service-account-token"
# }

resource "helm_release" "argo_workflows" {
  depends_on = [module.eks]

  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = "0.40.14"
  create_namespace = true
  namespace  = "argo"

  set {
    name  = "workflow.serviceAccount.create"
    value = "true"
  }
  
  set {
    name = "workflow.rbac.create"
    value = "true"
  }
}