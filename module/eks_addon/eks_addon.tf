resource "aws_eks_addon" "default" {
  cluster_name  = var.eks_cluster_name
  addon_name    = var.eks_addon_name
  addon_version = var.eks_addon_version
}
