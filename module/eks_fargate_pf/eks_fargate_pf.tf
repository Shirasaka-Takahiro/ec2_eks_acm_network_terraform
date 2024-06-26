resource "aws_eks_fargate_profile" "default" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = var.fargate_profile_name
  pod_execution_role_arn = var.fargate_profile_exec_role
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = var.fargate_profile_selector_name
  }
}