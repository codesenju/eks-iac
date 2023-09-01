# data "aws_eks_cluster" "eks" {
#   name = var.cluster_name
#   depends_on = [ module.eks ]
# }

# data "aws_eks_cluster" "argocd_eks" {
#   name = var.argocd_cluster_name
# }