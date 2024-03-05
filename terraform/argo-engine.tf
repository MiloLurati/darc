resource "null_resource" "create_argo_namespace" {
  depends_on = [module.eks, null_resource.update_kubeconfig]

  provisioner "local-exec" {
    command = "kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -"
  }
}
resource "null_resource" "deploy_argo" {
  # Ensures this resource is created after the cluster
  depends_on = [
    module.eks,null_resource.update_kubeconfig,null_resource.create_argo_namespace
  ]

  provisioner "local-exec" {
    command = <<EOT
      kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.5/install.yaml
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}