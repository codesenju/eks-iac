
data "aws_availability_zones" "available" {}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  # name = "education-vpc"
  name = var.vpc_name

  # cidr = "10.0.0.0/16"
  cidr = var.cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)

  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}"   = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    "karpenter.sh/discovery"                      = "${var.cluster_name}"
  }

}