data "external" "amp-token" {
  program = ["/bin/bash", "${path.module}/get-token.sh"]
}

resource "kubernetes_deployment" "ampserver_test" {
  metadata {
    name = "ampserver-test"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ampserver-test"

        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app = "ampserver-test"

          version = "v1"
        }
      }

      spec {
        container {
          name  = "ampserver-test"
          image = "grassshrimp/ampserver-test"

          port {
            container_port = 3000
          }

          env {
            name  = "AMPServer"
            value = "http://apm-server-quickstart-apm-http.elastic-system.svc.cluster.local:8200"
          }

          env {
            name  = "Port"
            value = "3000"
          }

          env {
            name  = "AMPSecretToken"
            value = data.external.amp-token.result.token
          }

          image_pull_policy = "Always"
        }
      }
    }
  }
}
resource "kubernetes_service" "ampserver-test" {
  metadata {
    name = "ampserver-test"
    labels = {
      app = "ampserver-test"
      service = "ampserver-test"
    }
  }
  spec {
    selector = {
      app = "ampserver-test"
    }
    
    port {
      port        = 3000
      target_port = 3000
      name        = "http"
    }

    type = "ClusterIP"
  }
  depends_on = [ kubernetes_deployment.ampserver_test ]
}
resource "kubernetes_manifest" "ingressRoute" {
  provider = kubernetes-alpha
  depends_on = [ kubernetes_service.ampserver-test ]

  manifest = yamldecode(
  <<EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: ampserver-test
    namespace: default
  spec:
    entryPoints:
    - web
    routes:
    - kind: Rule
      match: Host(`ampserver-test.${var.domain}`)
      services:
      - name: ampserver-test
        port: 3000
  EOF
  )
}