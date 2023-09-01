argocd_cluster_name = "uat"
cluster_name = "dev"
argocd_dest_server = "https://kubernetes.default.svc"
cluster_version=1.26
cert_arn = "arn:aws:acm:us-east-1:587878432697:certificate/a850a4a0-11c0-41a3-9a4a-4288f0c6be7d"
cidr = "192.168.0.0/16"
# cidr = "100.64.0.0/10"
# number_of_azs should equal the number off private_subnets
number_of_azs = 4
public_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
private_subnets = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24","192.168.7.0/24"]
# public_subnets = ["100.64.1.0/24", "100.64.2.0/24"]
# private_subnets = ["100.64.3.0/24", "100.64.4.0/24", "100.64.5.0/24","100.64.6.0/24"]
vpc_name = "dev-vpc"
# region = "us-east-2"
# azs = ["eu-east-1a", "eu-east-1b", "eu-east-1c"]
karpenter_namespace = "karpenter"
karpenter_version   = "v0.28.0"