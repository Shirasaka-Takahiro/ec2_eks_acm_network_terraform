resource "aws_eks_fargate_profile" "default" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = "${var.general_config["project"]}-${var.general_config["env"]}-profile"
  pod_execution_role_arn = var.fargate_profile_exec_role
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = var.fargate_profile_selector_name
  }
}