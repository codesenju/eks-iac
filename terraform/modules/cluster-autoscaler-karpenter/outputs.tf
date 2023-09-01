output "node_role_arn" {
   description = "The Amazon Resource Name (ARN) specifying the IAM role"
   value = module.karpenter.role_arn
}