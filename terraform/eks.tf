module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.4.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    group-1 = {
      name = "group1"

      instance_types = ["t2.micro"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 4
      desired_size = 1

      labels = {
        role = local.nodegroup1_label
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}"    = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/role" = "${local.nodegroup1_label}"
      }
    }

    group-2 = {
      name = "group2"

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 4
      desired_size = 1

      labels = {
        role = local.nodegroup2_label
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}"    = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/role" = "${local.nodegroup2_label}"
      }
    }
  }

  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true
}
