resource "kubernetes_manifest" "elasticsearch" {
  provider = kubernetes-alpha
  
  manifest = yamldecode(
  <<EOF
  apiVersion: elasticsearch.k8s.elastic.co/v1
  kind: Elasticsearch
  metadata:
    name: quickstart
    namespace: ${var.namespace}
  spec:
    version: 7.10.1
    nodeSets:
    - name: default
      count: 1
      config:
        node.store.allow_mmap: false
      volumeClaimTemplates:
      - metadata:
          name: elasticsearch-data
        spec:
          accessModes:
          - ReadWriteOnce
          resources:
            requests:
              storage: 5Gi
          storageClassName: ${var.storageClassName}
    http:
      tls:
        selfSignedCertificate:
          disabled: true
  EOF
  )
}

resource "kubernetes_manifest" "ingressRoute" {
  provider = kubernetes-alpha
  depends_on = [ kubernetes_manifest.elasticsearch ]

  manifest = yamldecode(
  <<EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: elasticsearch
    namespace: ${var.namespace}
  spec:
    entryPoints:
    - web
    routes:
    - match: Host(`elasticsearch.${var.domain}`)
      kind: Rule
      services:
      - name: quickstart-es-http
        port: 9200
  EOF
  )
}