
###################################
## IAM Role for Service Accounts ##
###################################
# Role for ServiceAccount to use
# Documentation:

locals {
  k8s_lb_service_account_namespace = "kube-system"
  k8s_lb_service_account_name      = "aws-load-balancer-controller"
  oidc_url                      = module.eks.cluster_oidc_issuer_url
  region                        = var.region
  # subnet_ids    = module.vpc.public_subnets.subnet_ids
}

module "irsa_awslb_controller" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "001_${module.eks.cluster_name}_${local.k8s_lb_service_account_name}"
  provider_url                  = module.eks.oidc_provider
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_lb_service_account_namespace}:${local.k8s_lb_service_account_name}"]
}

# How to attach managed aws policy to role
#resource "aws_iam_role_policy_attachment" "amazon_eks_awslb_policy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#  role       = module.iam_assumable_role_admin.iam_role_name
#}

# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/v5.27.0/modules/iam-assumable-role-with-oidc/main.tf
resource "aws_iam_role_policy" "awslb_controller_policy" {
   name = "${module.irsa_awslb_controller.iam_role_name}" # Takes name fromm the irsa_awslb_controller role
   role = module.irsa_awslb_controller.iam_role_name
  policy = jsonencode(
# json start
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "StringEquals": {
                    "elasticloadbalancing:CreateAction": [
                        "CreateTargetGroup",
                        "CreateLoadBalancer"
                    ]
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
}
# json end
  )
}

resource "helm_release" "awslb_controller" {
  depends_on = [ module.eks]
  name       = local.k8s_lb_service_account_name
  repository = "https://aws.github.io/eks-charts"
  chart      = local.k8s_lb_service_account_name
  version    = "1.5.0"
  namespace  = local.k8s_lb_service_account_namespace
  create_namespace = true
  wait = true
  timeout = "900" # wait longer for farget pods to be ready
  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "vpcId"
    value = module.network.vpc_id
  }
  set {
    name = "serviceAccount.create"
    value = "true"
  }

  set {
    name = "serviceAccount.name"
    value = local.k8s_lb_service_account_name
  }
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_awslb_controller.iam_role_arn
  }
}
#########################
#### Argocd Applicaiton ##
#########################
## https://github.com/aws/eks-charts/tree/master/stable/appmesh-controller
#resource "kubectl_manifest" "awslb_controller" {
#  provider = kubectl.argocd_cluster
#  depends_on = [ null_resource.role_mapping, module.eks ]
#  yaml_body = <<-YAML
#apiVersion: argoproj.io/v1alpha1
#kind: Application
#metadata:
#  name: ${module.eks.cluster_name}-${local.k8s_lb_service_account_name}-case
#  namespace: argocd
#  labels:
#    name: ${local.k8s_lb_service_account_name}
#    cluster:  ${module.eks.cluster_name}
#    type: case-work
#    tier: ingress-controllers
#spec:
#  project: default
#  source:
#    repoURL: https://aws.github.io/eks-charts
#    targetRevision: 1.5.5
#    chart: ${local.k8s_lb_service_account_name}
#    helm:
#      parameters:
#      - name: clusterName
#        value: ${module.eks.cluster_name}
#      - name: vpcId
#        value: ${module.network.vpc_id}
#      values: |
#        serviceAccount:
#          create: true
#          name: ${local.k8s_lb_service_account_name}
#          annotations:
#            eks.amazonaws.com/role-arn: ${module.irsa_awslb_controller.iam_role_arn}
#        replicaCount: 2
#  destination:
#    # cluster API URL
#    # server: https://kubernetes.default.svc
#    # or cluster name
#    name: ${module.eks.cluster_name}
#    namespace:  ${local.k8s_lb_service_account_namespace}
#  syncPolicy:
#    automated:
#      prune: true
#      selfHeal: true
#    syncOptions:
#    - CreateNamespace=true
#  YAML
#}
#
## Test Application