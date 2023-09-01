# locals {
#   k8s_nginx_app_name = "ingress-nginx"
# }
# ########################
# ## Argocd Applicaiton ##
# ########################
# # https://github.com/aws/eks-charts/tree/master/stable/appmesh-controller
# resource "kubectl_manifest" "argocd_ebs" {
#   provider = kubectl.argocd_cluster
#   yaml_body = <<-YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: ${module.eks.cluster_name}-i${local.k8s_nginx_app_name}-case
#   # You'll usually want to add your resources to the argocd namespace.
#   namespace: argocd
#   # Add this finalizer ONLY if you want these to cascade delete.
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
#   # Add labels to your application object.
#   labels:
#     name:  i${local.k8s_nginx_app_name}
#     cluster: ${var.cluster_name}
#     type: case-work
#     tier: ingress-controllers
#     iac: terraform
# spec:
#   project: default
#   source:
#     repoURL: https://kubernetes.github.io/ingress-nginx
#     targetRevision: 4.6.0
#     chart:  i${local.k8s_nginx_app_name}
#     helm:
#       values: |
#         controller:
#           affinity:
#             nodeAffinity:
#               requiredDuringSchedulingIgnoredDuringExecution:
#                 nodeSelectorTerms:
#                 - matchExpressions:
#                   - key: failure-domain.beta.kubernetes.io/zone
#                     operator: In
#                     values:
#                     - us-east-1a
#                     - us-east-1b
#                     - us-east-1c
#           replicaCount: 1
#           resources:
#             limits:
#               cpu: 400m
#               memory: 360Mi
#             requests:
#               cpu: 200m
#               memory: 180Mi
#           service:
#             targetPorts:
#               http: http
#               https: http
#             annotations:
#               prometheus.io/scrape: "true"
#               prometheus.io/port: "10254"
#               service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
#               service.beta.kubernetes.io/aws-load-balancer-type: external # This annotation should not be modified after service creation.
#               service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
#               service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
#               service.beta.kubernetes.io/aws-load-balancer-name: i${local.k8s_nginx_app_name}-${var.cluster_name}-case # This annotation should not be modified after service creation.
#               service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
#               service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
#               service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${var.cert_arn}
#               service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
#               service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: /healthz
#               service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: auto-delete=no
#   destination:
#     server: ${var.argocd_dest_server}
#     namespace:  i${local.k8s_nginx_app_name}
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#     syncOptions:
#     - CreateNamespace=true
#   YAML
# }