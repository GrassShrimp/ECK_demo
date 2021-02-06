resource "kubernetes_manifest" "kibana" {
  provider = kubernetes-alpha
  
  manifest = yamldecode(
  <<EOF
  apiVersion: kibana.k8s.elastic.co/v1
  kind: Kibana
  metadata:
    name: quickstart
    namespace: ${var.namespace}
  spec:
    version: 7.10.1
    count: 1
    elasticsearchRef:
      name: quickstart
      namespace: ${var.namespace}
    http:
      tls:
        selfSignedCertificate:
          disabled: true
  EOF
  )
}

resource "kubernetes_manifest" "ingressRoute" {
  provider = kubernetes-alpha
  
  manifest = yamldecode(
  <<EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: kibana
    namespace: ${var.namespace}
  spec:
    entryPoints:
    - web
    routes:
    - match: Host(`kibana.${var.domain}`)
      kind: Rule
      services:
      - name: quickstart-kb-http
        port: 5601
  EOF
  )
}