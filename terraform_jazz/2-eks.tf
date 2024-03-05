
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = "my-argo-eks-test"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "spot"
      }

      taints = [{
        key    = "market"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "staging"
  }
}

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region eu-west-1 --name my-argo-eks-test"
  }
}
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