resource "null_resource" "kibana" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./kibana.yaml -n ${var.namespace}"
    working_dir = path.module
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ./ingress_route.yaml -n ${var.namespace}"
    working_dir = path.module
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f ./ingress_route.yaml -n elastic-system"
    working_dir = path.module
  }
}