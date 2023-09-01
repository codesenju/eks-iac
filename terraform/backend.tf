
# AWS_REGION=$(aws configure get region)
# aws s3 mb s3://terraform-state-k8s-iac --region $AWS_REGION
# print yes | terraform init -migrate-state | terraform apply -auto-approve
terraform {
  backend "s3" {
    bucket         = "terraform-state-k8s-iac"
    key            = "terraform_eks_gitlab.tfstate"
    region         = "us-east-1"
    encrypt        = true
    workspace_key_prefix = "terraform_eks_gitlab"
  }
}

# A module may declare either one 'cloud' block configuring Terraform Cloud OR one 'backend' block configuring a state backend. Terraform Cloud is configured at terraform.tf:6,3-8; a backend is configured at backend.tf:6,3-15.
# │ Remove the backend block to configure Terraform Cloud.