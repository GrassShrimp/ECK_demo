resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "9.14.2"
  namespace  = "traefik"

  values = [
    <<EOF
      additionalArguments:
      - --api.insecure=true
      logs:
        general:
          level: INFO
        access:
          enabled: true
      ingressRoute:
        dashboard:
          enabled: false
      ports:
        traefik:
          port: 8080
          exposedPort: 9000
        web:
          port: 80
        websecure:
          port: 443
      persistence:
        enabled: true
        storageClass: ${var.storageClassName}
    EOF
  ]
}

resource "kubernetes_manifest" "ingressRoute" {
  provider = kubernetes-alpha
  
  manifest = yamldecode(
  <<EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: traefik-dashboard
    namespace: ${helm_release.traefik.namespace}
  spec:
    entryPoints:
    - web
    routes:
    - match: Host(`traefik.${var.domain}`)
      kind: Rule
      services:
      - name: api@internal
        kind: TraefikService
  EOF
  )  
}