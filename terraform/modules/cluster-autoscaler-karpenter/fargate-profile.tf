# # Fargate Profile | karpenter
# module "karpenter_fargate_profile" {
#   source = "terraform-aws-modules/eks/aws//modules/fargate-profile"
#   name = "karpanter-fargate-profile"
#   cluster_name = var.cluster_name
#   # subnet_ids = data.aws_subnets.eks_private_subnet_ids.ids
#   subnet_ids = var.fargate_private_subnets
#   selectors = [{ namespace = "karpenter" }]
# }
# 
# # Fargate Profile | kube-system
# module "kube_system_fargate_profile" {
#   source = "terraform-aws-modules/eks/aws//modules/fargate-profile"
#   name = "kube-system-fargate-profile"
#   cluster_name = var.cluster_name
#   # subnet_ids = data.aws_subnets.eks_private_subnet_ids.ids
#   subnet_ids = var.fargate_private_subnets
#   selectors = [{ namespace = "kube-system" }]
# }