# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# null_resource is generally not preferrable but it is simple to implement.
# For production use, use other methods e.g. https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
# Need eksctl to function properly
resource "null_resource" "modify_aws_auth" {
  triggers = {
    iam_role_arn = module.karpenter.role_arn
    cluster      = var.cluster_name
  }

  depends_on = [
   module.karpenter
  ]

  provisioner "local-exec" {
    on_failure  = fail
    when        = create
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            eksctl create iamidentitymapping \
                --username system:node:{{EC2PrivateDNSName}} \
                --cluster ${self.triggers.cluster} \
                --arn ${self.triggers.iam_role_arn} \
                --group system:bootstrappers \
                --group system:nodes
        EOT
  }

  provisioner "local-exec" {
    on_failure  = continue
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            eksctl delete iamidentitymapping \
                --cluster ${self.triggers.cluster} \
                --arn ${self.triggers.iam_role_arn}
        EOT
  }
}
