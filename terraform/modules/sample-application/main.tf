resource "kubectl_manifest" "game_2048_namespace" {
  yaml_body = <<-YAML
apiVersion: v1
kind: Namespace
metadata:
  name: game-2048
YAML
}
resource "kubectl_manifest" "game_2048_deployment" {
  depends_on = [ kubectl_manifest.game_2048_namespace ]
    yaml_body = <<-YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: game-2048
  name: deployment-2048
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2048
  replicas: 3
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2048
    spec:
      containers:
      - image: public.ecr.aws/l6m2t8p7/docker-2048:latest
        imagePullPolicy: Always
        name: app-2048
        ports:
        - containerPort: 80
YAML
}
resource "kubectl_manifest" "game_2048_service" {
   depends_on = [ kubectl_manifest.game_2048_namespace ]
    yaml_body = <<-YAML
apiVersion: v1
kind: Service
metadata:
  namespace: game-2048
  name: service-2048
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: NodePort
  selector:
    app.kubernetes.io/name: app-2048
YAML
}
resource "kubectl_manifest" "game_2048_ingress" {
   depends_on = [ kubectl_manifest.game_2048_namespace ]
    yaml_body = <<-YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: game-2048
  name: ingress-2048
  annotations:
    alb.ingress.kubernetes.io/group.name: ${var.cluster_name}-eks
    alb.ingress.kubernetes.io/scheme: ${var.internet_facing ? "internet-facing" : "internal"}
    alb.ingress.kubernetes.io/target-type: ${var.instance_target_type ? "instance" : "ip"}
    ## SSL Settings ##
    alb.ingress.kubernetes.io/certificate-arn: ${var.certificate_arn}
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}, {"HTTP":80}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  ingressClassName: ${var.ingress_class_name}
  rules:
  - host: ${var.host}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service-2048
            port:
              number: 80
YAML
}