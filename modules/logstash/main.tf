resource "helm_release" "logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = "7.12.0"
  namespace  = "logstash"
  
  values = [
    "${file("${path.module}/values.yaml")}"
  ]

  create_namespace = "true"
}

# resource "kubernetes_manifest" "beats" {
#   provider = kubernetes-alpha

#   manifest = yamldecode(
#   <<EOF
#   kind: Service
#   apiVersion: v1
#   metadata:
#     name: istio-ingressgateway
#     namespace: istio-system
#   spec:
#     ports:
#     - name: beats
#       protocol: TCP
#       port: 5044
#       targetPort: 5044
#   EOF
#   )
# }
