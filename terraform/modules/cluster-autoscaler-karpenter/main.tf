# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Documentation: 
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/examples/karpenter
# - https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v19.15.3/examples/karpenter/outputs.tf
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name           = var.cluster_name
  irsa_oidc_provider_arn = var.irsa_oidc_provider_arn
  
  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    
  }
  
  #tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = module.karpenter.role_name
}

## Useful if later you want to add cloudwatch as a datasource in grafana ##
# https://docs.aws.amazon.com/grafana/latest/userguide/adding--CloudWatch-manual.html#CloudWatch-authentication
# Attach a custom policy to the role
resource "aws_iam_role_policy" "grafana_coudwatch_datasource" {
  name   = "001_grafana_coudwatch_datasource"
  role   = module.karpenter.role_name
  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadingMetricsFromCloudWatch",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetInsightRuleReport"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingLogsFromCloudWatch",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:GetLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingTagsInstancesRegionsFromEC2",
      "Effect": "Allow",
      "Action": ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingResourcesForTags",
      "Effect": "Allow",
      "Action": "tag:GetResources",
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingAcrossAccounts",
      "Effect": "Allow",
      "Action": [
        "oam:ListSinks",
        "oam:ListAttachedLinks"
      ],
      "Resource": "*"
    }
  ]
}
  )
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.28.0"
  namespace  = "karpenter"
  create_namespace = true
  wait = true
  timeout = "900" # wait longer for farget pods to be ready

  set {
    name = "serviceAccount.name"
    value = "karpenter"
  }
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value =  module.karpenter.irsa_arn
  }
    set {
    name = "settings.aws.clusterName"
    value = var.cluster_name
  }
    set {
    name = "settings.aws.clusterEndpoint"
    value = var.cluster_endpoint
  }
    set {
    name = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
      set {
    name = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }
      set {
    name = "settings.aws.featureGates.driftEnabled"
    value = true
  }
}

# Deploys kustomize manifest files via argocd application
resource "kubectl_manifest" "karpenter_awsnodetemplate" {
  depends_on = [helm_release.karpenter]
  yaml_body = <<-YAML
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
  labels:
    name: awsnodetemplate
  namespace: karpenter
spec:
  subnetSelector:
    karpenter.sh/discovery: ${var.cluster_name}
  securityGroupSelector:
    karpenter.sh/discovery: ${var.cluster_name}
  tags:
    auto-delete: "no"
    # The bellow tag is needed to avoid: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message: kZGXVHrRVyw...
    # Mandotory when using the terraform module: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/examples/karpenter
    karpenter.sh/discovery: ${var.cluster_name}
YAML
}
resource "kubectl_manifest" "karpenter_provisioner" {
  depends_on = [helm_release.karpenter]
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
  labels:
    name: provisioner
  namespace: karpenter
spec:
  consolidation:
    enabled: true
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot","on-demand"]
    - key: karpenter.k8s.aws/instance-cpu
      operator: In
      values:  ["4", "8", "16", "32"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: kubernetes.io/os
      operator: In
      values:
        - linux
    - key: karpenter.k8s.aws/instance-category
      operator: In
      values:
        - c
        - m
        - r
  limits:
    resources:
      cpu: 1k
  providerRef:
    name: default
#  ttlSecondsAfterEmpty: 30
  YAML
}