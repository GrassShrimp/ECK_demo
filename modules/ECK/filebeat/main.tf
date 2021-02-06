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

resource "kubernetes_manifest" "filebeat" {
  provider = kubernetes-alpha
  
  manifest = yamldecode(
  <<EOF
  apiVersion: beat.k8s.elastic.co/v1beta1
  kind: Beat
  metadata:
    name: quickstart
    namespace: ${var.namespace}
  spec:
    type: filebeat
    version: 7.10.1
    elasticsearchRef:
      name: quickstart
      namespace: ${var.namespace}
    config:
      filebeat:
        autodiscover:
          providers:
          - host: $${HOSTNAME}
            type: kubernetes
            hints:
              enabled: true
              default_config:
                type: container
                paths:
                - /var/log/containers/*$${data.kubernetes.container.id}.log
    daemonSet:
      podTemplate:
        spec:
          serviceAccount: ${kubernetes_service_account.filebeat.metadata[0].name}
          automountServiceAccountToken: true
          dnsPolicy: ClusterFirstWithHostNet
          hostNetwork: true
          securityContext:
            runAsUser: 0
          containers:
          - name: filebeat
            volumeMounts:
            - name: varlogcontainers
              mountPath: /var/log/containers
            - name: varlogpods
              mountPath: /var/log/pods
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
          volumes:
          - name: varlogcontainers
            hostPath:
              path: /var/log/containers
          - name: varlogpods
            hostPath:
              path: /var/log/pods
          - name: varlibdockercontainers
            hostPath:
              path: /var/lib/docker/containers
  EOF
  )
}
