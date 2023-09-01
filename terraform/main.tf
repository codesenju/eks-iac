# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  vpc_name = var.vpc_name
  cidr = var.cidr
  number_of_azs = var.number_of_azs
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  cluster_name = var.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id                         = module.network.vpc_id
  subnet_ids                     = module.network.private_subnets
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      most_recent = true
      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn = module.irsa_vpc_cni.iam_role_arn
    }
    aws-ebs-csi-driver = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn = module.irsa_ebs_csi.iam_role_arn
    }
    
  }

  enable_irsa = true

  create_kms_key = false
  cluster_encryption_config = {}
  enable_kms_key_rotation = false

  fargate_profiles = {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }

}

module "karpenter" {
  region = var.region
  source = "./modules/cluster-autoscaler-karpenter"
  karpenter_version = var.karpenter_version
  karpenter_namespace = var.karpenter_namespace
  argocd_cluster_name = var.argocd_cluster_name
  argocd_dest_server = var.argocd_dest_server
  cluster_name = var.cluster_name
  fargate_private_subnets = module.network.private_subnets
  vpc_id = module.network.vpc_id
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_security_group_id = module.eks.cluster_primary_security_group_id
}

## Sample Application ##
module "sample_application" {
 source = "./modules/sample-application"
 host = "prod-game-2048.lmasu.co.za"
 ingress_class_name = "alb"
 internet_facing = true
 instance_target_type = false
 cluster_name = var.cluster_name
 cluster_endpoint = module.eks.cluster_endpoint
 cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
 certificate_arn = var.cert_arn
}