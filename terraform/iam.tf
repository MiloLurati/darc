module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.35.0" 
  create_role                   = true
  role_name                     = "cluster-autoscaler"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_user" "iam_user" {
  name = var.iam_user
}

# Encrypted key can be retrieved usig `terraform output` after `terraform apply`
resource "aws_iam_access_key" "iam_user_key" {
  user = aws_iam_user.iam_user.name
}

data "aws_iam_policy_document" "iam_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]  # TODO: Change to actions we need
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "test"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.iam_policy.json
}