variable "host" { 
  description = "Application URL"
  type = string
}

variable "internet_facing" {
  type = bool
}
variable "instance_target_type" {
   type = bool
}

variable "ingress_class_name" {
  description = "ingressClassName to be used - alb|nginx ?"
  type = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type = string
}

variable "cluster_certificate_authority_data" {
   type = string
}

variable "certificate_arn" {
  description = "Certificate to be attached to the https listener"
  type = string
}