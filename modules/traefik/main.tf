resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "9.18.3"
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

  create_namespace = true

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=Established --all crd"
  }
}

resource "null_resource" "ingressRoute" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./ingress_route.yaml -n ${helm_release.traefik.namespace}"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f ./ingress_route.yaml -n traefik"
    working_dir = path.module
  }
}