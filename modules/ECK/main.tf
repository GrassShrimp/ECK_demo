resource "helm_release" "eck-operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "1.5.0"
  namespace  = "elastic-system"

  values = [
    <<EOF
    webhook:
      enabled: false
    EOF
  ]

  create_namespace = true

  provisioner "local-exec" {
    command = "kubectl wait --for=condition=Established --all crd"
  }
}

module "elasticsearch" {
  source = "./elasticsearch"

  namespace = helm_release.eck-operator.namespace
}

module "kibana" {
  source = "./kibana"

  namespace = helm_release.eck-operator.namespace
}

module "apmServer" {
  source = "./apmServer"

  namespace = helm_release.eck-operator.namespace
}

module "filebeat" {
  source = "./filebeat"

  namespace = helm_release.eck-operator.namespace
}