
###################################
## IAM Role for Service Accounts ##
###################################
# https://github.com/aws/eks-charts/tree/master/stable/appmesh-controller
# Deploys kustomize manifest files via argocd application
locals {
  k8s_externaldns_service_name = "external-dns"
  k8s_externaldns_service_namespace = "kube-system"
}

module "irsa_external_dns_contoller" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "001_${module.eks.cluster_name}_${local.k8s_externaldns_service_name}"
  provider_url                  = module.eks.oidc_provider
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_externaldns_service_namespace}:${local.k8s_externaldns_service_name}"]
}

# How to attach managed aws policy to role
#resource "aws_iam_role_policy_attachment" "amazon_eks_awslb_policy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#  role       = module.iam_assumable_role_admin.iam_role_name
#}

# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/v5.27.0/modules/iam-assumable-role-with-oidc/main.tf
resource "aws_iam_role_policy" "external_dns_controller_policy" {
   name = "${module.irsa_external_dns_contoller.iam_role_name}" # Takes name fromm the irsa_external_dns_contoller role
   role = module.irsa_external_dns_contoller.iam_role_name
  policy = jsonencode(
# json start
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
# json end
  )
}

resource "helm_release" "external_dns" {
  depends_on = [ module.eks]
  name       = local.k8s_externaldns_service_name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = local.k8s_externaldns_service_name
  version    = "1.13.0"
  namespace  = local.k8s_externaldns_service_namespace
  create_namespace = true
  wait = true
  timeout = "900" # wait longer for farget pods to be ready
  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = "true"
  }

  set {
    name = "serviceAccount.name"
    value = local.k8s_externaldns_service_name
  }
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_external_dns_contoller.iam_role_arn
  }
  set {
    name = "domainFilters"
    value = "{lmasu.co.za,example.com}"
  }

  set {
    name = "txtOwnerId"
    value = local.k8s_externaldns_service_name
  }

  set {
    name =  "provider"
    value = "aws"
  }
}


# ########################
# ## Argocd Applicaiton ##
# ########################

# resource "kubectl_manifest" "external_dns" {
#   provider = kubectl.argocd_cluster
#   depends_on = [ null_resource.role_mapping ]
#   yaml_body = <<-YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: ${module.eks.cluster_name}-${local.k8s_externaldns_service_name}
#   namespace: argocd
#   labels:
#     name: ${local.k8s_externaldns_service_name}
#     cluster: ${module.eks.cluster_name}
#     type: system
#     tier: networking
#     iac: terraform
# spec:
#   project: default
#   source:
#     repoURL: https://kubernetes-sigs.github.io/external-dns/
#     targetRevision: 1.13.0
#     chart: ${local.k8s_externaldns_service_name}
#     helm:
#       releaseName: ${local.k8s_externaldns_service_name}
#       values: |
#         serviceAccount:
#           create: true
#           name: ${local.k8s_externaldns_service_name}
#           annotations:
#             eks.amazonaws.com/role-arn: ${module.irsa_external_dns_contoller.iam_role_arn}
#         provider: aws
#         domainFilters:
#           - lmasu.co.za
#           - example.com
#         txtOwnerId: "${local.k8s_externaldns_service_name}"
#   destination:
#     name: ${module.eks.cluster_name}
#     namespace: ${local.k8s_externaldns_service_namespace}
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#     syncOptions:
#     - CreateNamespace=true
#   YAML
# }