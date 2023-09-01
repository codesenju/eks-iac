# Prerequisites
### The follwing role/user should be in the new cluster's and argocd cluster's aws-auth config map.
```bash
aws sts get-caller-identity
{
    "UserId": "*****************",
    "Account": "AWS_ACCOUNT_ID",
    "Arn": "arn:aws:iam::AWS_ACCOUNT_ID:user/cli-user"
}
```
### For argocd applicaitons to work we need to add the newly created cluster to argocd server

```bash
argocd login argocd.lmasu.co.za                                             
# Username: admin
# Password: 
#'admin:login' logged in successfully
# Context 'argocd.lmasu.co.za' updated


CURRENT   NAME                                                   CLUSTER                                                AUTHINFO                                               NAMESPACE
*         arn:aws:eks:us-east-1:AWS_ACCOUNT_ID:cluster/CLUSTER_NAME         arn:aws:eks:us-east-1:AWS_ACCOUNT_ID:cluster/dev         arn:aws:eks:us-east-1:AWS_ACCOUNT_ID:cluster/CLUSTER_NAME  

argocd cluster add arn:aws:eks:us-east-1:AWS_ACCOUNT_ID:cluster/CLUSTER_NAME  --name CLUSTER_NAME
#WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `arn:aws:eks:us-east-1:587878432697:cluster/dev` with full cluster level privileges. Do you want to continue [y/N]? y
#INFO[0005] ServiceAccount "argocd-manager" created in namespace "kube-system" 
#INFO[0005] ClusterRole "argocd-manager-role" created    
#INFO[0006] ClusterRoleBinding "argocd-manager-role-binding" created 
#INFO[0012] Created bearer token secret for ServiceAccount "argocd-manager" 
#Cluster 'https://DCA74BBB07C80CC02993A19E4BDC474D.gr7.us-east-1.eks.amazonaws.com' added
```