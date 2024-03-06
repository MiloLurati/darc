locals {
  cluster_name = "darc-eks"
  nodegroup1_label = "group1"
  nodegroup2_label = "group2"
}

locals {

  eks_asg_tag_list_nodegroup1 = {
    "k8s.io/cluster-autoscaler/enabled" : true
    "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    "k8s.io/cluster-autoscaler/node-template/label/role" : local.nodegroup1_label
  }

  eks_asg_tag_list_nodegroup2 = {
    "k8s.io/cluster-autoscaler/enabled" : true
    "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    "k8s.io/cluster-autoscaler/node-template/label/role" : local.nodegroup2_label
    "k8s.io/cluster-autoscaler/node-template/taint/dedicated" : "${local.nodegroup2_label}:NoSchedule"
  }
}

locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler"
}