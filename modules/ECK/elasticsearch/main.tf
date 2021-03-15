resource "null_resource" "elasticsearch" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./elasticsearch.yaml -n ${var.namespace}"
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