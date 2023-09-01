# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# null_resource is generally not preferrable but it is simple to implement.
# For production use, use other methods e.g. https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
# Need eksctl to function properly
resource "null_resource" "role_mapping" {
  depends_on = [ module.eks ]
  triggers = {
    iam_role_arn = "arn:aws:iam::587878432697:user/cli-user"
    cluster      = module.eks.cluster_name
  }

  provisioner "local-exec" {
    on_failure  = fail
    when        = create
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            eksctl create iamidentitymapping \
                --username "cluster-admin" \
                --cluster ${self.triggers.cluster} \
                --arn ${self.triggers.iam_role_arn} \
                --group system:masters
        EOT
  }

  provisioner "local-exec" {
    on_failure  = fail
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            eksctl delete iamidentitymapping \
                --cluster ${self.triggers.cluster} \
                --arn ${self.triggers.iam_role_arn}
        EOT
  }
}
