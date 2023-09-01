resource "null_resource" "tag_cluster_security_group" {
  triggers = {
    cluster_security_group_id = var.cluster_security_group_id
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    on_failure  = fail
    when        = create
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            aws ec2 create-tags --resources ${self.triggers.cluster_security_group_id} --tags Key=karpenter.sh/discovery,Value=${self.triggers.cluster_name}
        EOT
  }

  provisioner "local-exec" {
    on_failure  = continue
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
            aws ec2 delete-tags --resources ${self.triggers.cluster_security_group_id} --tags Key=karpenter.sh/discovery,Value=${self.triggers.cluster_name}
        EOT
  }
}
