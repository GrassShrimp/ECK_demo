resource "helm_release" "eck-operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "1.3.1"
  namespace  = "elastic-system"

  values = [
    <<EOF
    installCRDs: false
    webhook:
      enabled: false
    EOF
  ]
}

module "elasticsearch" {
  source = "./elasticsearch"

  namespace = helm_release.eck-operator.namespace
  domain = var.domain
  storageClassName = var.storageClassName
}

module "kibana" {
  source = "./kibana"

  namespace = helm_release.eck-operator.namespace
  domain = var.domain
}

module "apmServer" {
  source = "./apmServer"

  namespace = helm_release.eck-operator.namespace
}

module "filebeat" {
  source = "./filebeat"

  namespace = helm_release.eck-operator.namespace
}