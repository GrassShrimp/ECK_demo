resource "kubernetes_manifest" "apmServer" {
  provider = kubernetes-alpha
  
  manifest = yamldecode(
  <<EOF
  apiVersion: apm.k8s.elastic.co/v1
  kind: ApmServer
  metadata:
    name: apm-server-quickstart
    namespace: ${var.namespace}
  spec:
    version: 7.10.1
    count: 1
    elasticsearchRef:
      name: quickstart
      namespace: ${var.namespace}
    kibanaRef:
      name: quickstart
      namespace: ${var.namespace}
    http:
      tls:
        selfSignedCertificate:
          disabled: true
  EOF
  )
}

# data "external" "apm-token" {
#   program = ["/bin/bash", "-c", "kubectl get secret/apm-server-quickstart-apm-token -n elastic-system -o jsonpath={@.data} || true"]

#   depends_on = [ kubernetes_manifest.apmServer ]
# }