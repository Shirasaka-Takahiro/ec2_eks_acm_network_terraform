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