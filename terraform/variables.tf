# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "Cluster version"
  type        = string
}
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "argocd_cluster_name" {
  description = "The name of the cluster where argocd is installed"
  type        = string
}

variable "argocd_dest_server" {
  description = "Destination EKS server managed by argocd"
  type        = string
}

variable "cert_arn" {
 description = "ARN of the certificate to be attached to the NLB"
 type = string
}

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "myVpc"
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
#  default     = "100.64.0.0/10"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "number_of_azs" {
  description = "The number of azs in the VPC"
  type        = number
  default     = 4
}

## karpenter ##
variable "karpenter_namespace" {
  description = "The K8S namespace to deploy Karpenter into"
  default     = "karpenter"
  type        = string
}

variable "karpenter_version" {
  description = "Karpenter Version"
  default     = "0.10.0"
  type        = string
}

# variable "irsa_oidc_provider_arn" {
#   description = "OIDC PROVIDER ARN"
#   type = string
# }
