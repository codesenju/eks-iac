# locals {
#   k8s_app_name = "game-2048"
# }
# ########################
# ## Argocd Applicaitons ##
# ########################
# # https://github.com/aws/eks-charts/tree/master/stable/appmesh-controller
# resource "kubectl_manifest" "argocd_game_2048" {
#   depends_on = [ kubectl_manifest.awslb_controller ]
#   provider = kubectl.argocd_cluster
#   yaml_body = <<-YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: ${module.eks.cluster_name}-${local.k8s_app_name}
#   # You'll usually want to add your resources to the argocd namespace.
#   namespace: argocd
#   # Add this finalizer ONLY if you want these to cascade delete.
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
#   # Add labels to your application object.
#   labels:
#     name:  ${local.k8s_app_name}
#     cluster: ${module.eks.cluster_name}
#     type: case-work
#     iac: terraform
# spec:
#   project: default
#   source:
#     repoURL: https://github.com/kubernetes-sigs/aws-load-balancer-controller.git
#     targetRevision: v2.5.4
#     path:    docs/examples/2048/
#     directory:
#       include: '2048_full.yaml'
#   destination:
#     name:  ${module.eks.cluster_name}
#     namespace:  ${local.k8s_app_name}
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#     syncOptions:
#     - CreateNamespace=true
#   YAML
# }
# # https://github.com/aws/eks-charts/tree/master/stable/appmesh-controller
# resource "kubectl_manifest" "argocd_game_2048_internal" {
#   depends_on = [ kubectl_manifest.awslb_controller ]
#   provider = kubectl.argocd_cluster
#   yaml_body = <<-YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: ${module.eks.cluster_name}-${local.k8s_app_name}
#   # You'll usually want to add your resources to the argocd namespace.
#   namespace: argocd
#   # Add this finalizer ONLY if you want these to cascade delete.
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
#   # Add labels to your application object.
#   labels:
#     name:  ${local.k8s_app_name}
#     cluster: ${module.eks.cluster_name}
#     type: case-work
#     iac: terraform
# spec:
#   project: default
#   source:
#     repoURL: git@github.com:codesenju/AWS-PSE-DOC.git
#     targetRevision: uat
#     path:    EKS/Networking/Exposing_Pods/AWS_Load_Balancer_Controller/deploy
#     # directory:
#     #   include: '2048_full.yaml'
#   destination:
#     name:  ${module.eks.cluster_name}
#     namespace:  ${local.k8s_app_name}
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#     syncOptions:
#     - CreateNamespace=true
#   YAML
# }