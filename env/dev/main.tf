##Provider for ap-northeast-1
provider "aws" {
  profile    = "terraform-user"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "ap-northeast-1"
}

##Network
module "network" {
  source = "../../module/network"

  general_config          = var.general_config
  availability_zones      = var.availability_zones
  vpc_id                  = module.network.vpc_id
  vpc_cidr                = var.vpc_cidr
  internet_gateway_id     = module.network.internet_gateway_id
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets
  public_subnet_ids       = module.network.public_subnet_ids
  private_route_table_ids = module.network.private_route_table_ids
}

##Security Group Internal
module "internal_sg" {
  source = "../../module/securitygroup"

  general_config = var.general_config
  vpc_id         = module.network.vpc_id
  from_port      = 0
  to_port        = 0
  protocol       = "-1"
  cidr_blocks    = ["10.0.0.0/16"]
  sg_role        = "internal"
}

##Secutiry Group Operation
module "operation_sg_1" {
  source = "../../module/securitygroup"

  general_config = var.general_config
  vpc_id         = module.network.vpc_id
  from_port      = 22
  to_port        = 22
  protocol       = "tcp"
  cidr_blocks    = var.operation_sg_1_cidr
  sg_role        = "operation_1"
}

module "operation_sg_2" {
  source = "../../module/securitygroup"

  general_config = var.general_config
  vpc_id         = module.network.vpc_id
  from_port      = 22
  to_port        = 22
  protocol       = "tcp"
  cidr_blocks    = var.operation_sg_2_cidr
  sg_role        = "operation_2"
}

module "operation_sg_3" {
  source = "../../module/securitygroup"

  general_config = var.general_config
  vpc_id         = module.network.vpc_id
  from_port      = 22
  to_port        = 22
  protocol       = "tcp"
  cidr_blocks    = var.operation_sg_3_cidr
  sg_role        = "operation_3"
}

module "alb_http_sg" {
  source = "../../module/securitygroup"

  general_config = var.general_config
  vpc_id         = module.network.vpc_id
  from_port      = 80
  to_port        = 80
  protocol       = "tcp"
  cidr_blocks    = ["0.0.0.0/0"]
  sg_role        = "alb_http"
}

module "alb_https_sg" {
  source = "../../module/securitygroup"

  general_config = var.general_config
  vpc_id         = module.network.vpc_id
  from_port      = 443
  to_port        = 443
  protocol       = "tcp"
  cidr_blocks    = ["0.0.0.0/0"]
  sg_role        = "alb_https"
}

##EC2
module "ec2" {
  source = "../../module/ec2"

  general_config    = var.general_config
  ami               = var.ami
  public_subnets    = var.public_subnets
  public_subnet_ids = module.network.public_subnet_ids
  internal_sg_id    = module.internal_sg.security_group_id
  operation_sg_1_id = module.operation_sg_1.security_group_id
  operation_sg_2_id = module.operation_sg_2.security_group_id
  operation_sg_3_id = module.operation_sg_3.security_group_id
  ec2_role          = var.ec2_role
  key_name          = var.key_name
  public_key_path   = var.public_key_path
  instance_type     = var.instance_type
  volume_type       = var.volume_type
  volume_size       = var.volume_size
}

##S3
module "s3_alb_access_log" {
  source = "../../module/s3"

  general_config = var.general_config
  bucket_role    = "alb-access-log"
  iam_account_id = var.iam_account_id
}

##ACM
module "acm_alb" {
  source = "../../module/acm"

  zone_id     = var.zone_id
  domain_name = var.domain_name
  sans        = var.sans
}

##EKS
module "eks" {
  source = "../../module/eks"

  general_config                = var.general_config
  eks_cluster_role              = module.iam_eks_cluster.iam_role_arn
  private_subnet_ids            = module.network.private_subnet_ids
  internal_sg_id                = module.internal_sg.security_group_id
  eks_cluster_policy            = module.iam_eks_cluster.iam_policy_attachment_name
  eks_service_policy            = module.iam_eks_service.iam_policy_attachment_name
  fargate_profile_exec_role     = module.iam_fargate_profile_exec.iam_role_arn
  fargate_profile_selector_name = var.fargate_profile_selector_name
}

##IAM
module "iam_eks_cluster" {
  source = "../../module/iam"

  general_config = var.general_config
  role_name      = var.eks_cluster_role_name
  policy_name    = var.eks_cluster_policy_name
  role_json      = file("../../module/iam_role/eks_assume_role.json")
  policy_json    = file("../../module/iam_role/eks_cluster_policy.json")
}

module "iam_eks_service" {
  source = "../../module/iam"

  general_config = var.general_config
  role_name      = var.eks_service_role_name
  policy_name    = var.eks_service_policy_name
  role_json      = file("../../module/iam_role/eks_assume_role.json")
  policy_json    = file("../../module/iam_role/eks_service_policy.json")
}

module "iam_fargate_profile_exec" {
  source = "../../module/iam"

  general_config = var.general_config
  role_name      = var.fargate_profile_exec_role_name
  policy_name    = var.fargate_profile_exec_policy_name
  role_json      = file("../../module/iam_role/eks_fargate_assume_role.json")
  policy_json    = file("../../module/iam_role/eks_fargate_exec_policy.json")
}