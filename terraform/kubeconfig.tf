resource "null_resource" "update_kubeconfig" {
  depends_on = [module.vpc, module.eks, module.iam_assumable_role_admin, 
                aws_autoscaling_group_tag.nodegroup2, aws_autoscaling_group_tag.nodegroup1,
                aws_autoscaling_group_tag.nodegroup2, aws_iam_policy.cluster_autoscaler]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${local.cluster_name}"
  }
}