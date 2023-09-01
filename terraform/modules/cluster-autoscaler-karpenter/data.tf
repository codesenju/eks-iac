# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# data "aws_eks_cluster" "eks" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster" "argocd_eks" {
#   name = var.argocd_cluster_name
# }

# # Import EKS VPC
# data "aws_vpc" "eks_vpc" {
#   id = var.vpc_id
# }

# # Import EKS Subnet id's - Used to create Fargate Profile
# data "aws_subnets" "eks_private_subnet_ids" {
# filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
# 
#   tags = {
#     "aws-cdk:subnet-type" = "Private"
#   }
# }