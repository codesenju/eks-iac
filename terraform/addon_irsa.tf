# #################
# ## kube Proxy ##
# ################
# resource "aws_eks_addon" "kube_proxy" {
#    depends_on = [ module.eks ]
#   cluster_name = var.cluster_name
#   addon_name   = "kube-proxy"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
# }
# 
# #####################
# ## Amazon Core DNS ##
# #####################
# resource "aws_eks_addon" "coredns" {
#     depends_on = [ module.eks ]
#   cluster_name = var.cluster_name
#   addon_name   = "coredns"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
# }
# 
###############################
## EBS CSI Driver Controller ##
###############################
locals {
  k8s_ebs_service_account_name      = "ebs-csi-controller-sa"
  k8s_ebs_service_account_namespace = "kube-system"
}
# AWS Managed Policy
# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# IRSA for EBS Plugin Installation
module "irsa_ebs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"
  create_role                   = true
  role_name                     = "${module.eks.cluster_name}-AmazonEKSTFEBSCSIRole"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_ebs_service_account_namespace}:${local.k8s_ebs_service_account_name}"]
}

# # EBS Plugin addon
# resource "aws_eks_addon" "ebs-csi" {
#   cluster_name             = module.eks.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
#   tags = {
#     "eks_addon" = "ebs-csi"
#     "terraform" = "true"
#   }
# }

####################
## Amazon VPC CNI ##
####################
# IRSA for VPC CNI
# Documentation:
locals {
  k8s_vpccni_service_account_name      = "aws-node"
  k8s_vpccni_service_account_namespace = "kube-system"
}

module "irsa_vpc_cni" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "001_${var.cluster_name}_${local.k8s_vpccni_service_account_name}"
  provider_url                  = module.eks.oidc_provider
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_vpccni_service_account_namespace}:${local.k8s_vpccni_service_account_name}"]
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = module.irsa_vpc_cni.iam_role_name
}

# # VPC CNI Addon Installation
# resource "aws_eks_addon" "vpc_cni" {
#   depends_on = [ module.eks ]
#   cluster_name = var.cluster_name
#   addon_name   = "vpc-cni"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#   service_account_role_arn = module.irsa_vpc_cni.iam_role_arn
# }