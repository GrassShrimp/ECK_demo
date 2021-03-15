resource "null_resource" "apmServer" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./apm_server.yaml -n ${var.namespace}"
    working_dir = path.module
  }
}

# data "external" "apm-token" {
#   program = ["/bin/bash", "-c", "kubectl get secret/apm-server-quickstart-apm-token -n elastic-system -o jsonpath={@.data} || true"]

#   depends_on = [ kubernetes_manifest.apmServer ]
# }