resource "kubernetes_service_account" "filebeat" {
  metadata {
    name = "elastic-beat-filebeat-quickstart"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "filebeat" {
  metadata {
    name = "elastic-beat-autodiscover"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "namespaces", "events", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "filebeat" {
  metadata {
    name = "elastic-beat-autodiscover-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.filebeat.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.filebeat.metadata[0].name
    namespace = var.namespace
  }
}

resource "null_resource" "filebeat" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./filebeat.yaml -n ${var.namespace}"
    working_dir = path.module
  }
}
