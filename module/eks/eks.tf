resource "aws_eks_cluster" "default" {
  name     = "${var.general_config["project"]}-${var.general_config["env"]}-cluster"
  role_arn = var.eks_cluster_role

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.internal_sg_id]
  }

  depends_on = [
    var.eks_cluster_policy,
    var.eks_service_policy
  ]
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.default.name
  fargate_profile_name   = "${var.general_config["project"]}-${var.general_config["env"]}-profile"
  pod_execution_role_arn = var.fargate_profile_exec_role
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = var.fargate_profile_selector_name
  }
}