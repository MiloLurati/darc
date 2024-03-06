resource "aws_autoscaling_group_tag" "nodegroup1" {
  for_each               = local.eks_asg_tag_list_nodegroup1
  autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 0)

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
  depends_on = [ module.vpc, module.eks ]
}

resource "aws_autoscaling_group_tag" "nodegroup2" {
  for_each               = local.eks_asg_tag_list_nodegroup2
  autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 1)

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
  depends_on = [ module.vpc, module.eks ]
}

resource "helm_release" "cluster-autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = local.k8s_service_account_namespace
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.35.0"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = local.k8s_service_account_name
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.iam_role_arn
    type  = "string"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  
  depends_on = [module.vpc, module.eks, module.iam_assumable_role_admin, 
                aws_autoscaling_group_tag.nodegroup2, aws_autoscaling_group_tag.nodegroup1,
                aws_autoscaling_group_tag.nodegroup2, aws_iam_policy.cluster_autoscaler]
}


