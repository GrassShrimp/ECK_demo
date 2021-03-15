# ECK_demo

This is a demo for test ECK

## Prerequisites

- [terraform](https://www.terraform.io/downloads.html)
- [docker](https://www.docker.com/products/docker-desktop) and enable kubernetes

## Usage

check current context of kubernetes is __docker-desktop__

```bash
$ kubectl config current-context
```

initialize terraform module

```bash
$ terraform init && terraform apply "init.tfplan"
```

install traefik

```bash
$ terraform apply -target=module.traefik
```

![traefik dashbaord](https://github.com/GrassShrimp/ECK_demo/blob/master/traefik_dashboard.png)
install elasticsearch, kibana, filebeats, and apm server vi ECK operator

```bash
$ terraform apply -target=module.ECK
```

![kibana index managment](https://github.com/GrassShrimp/ECK_demo/blob/master/kibana_index_management.png)
![kibana log dashboard](https://github.com/GrassShrimp/ECK_demo/blob/master/kibana_log.png)
![kibana dashboard](https://github.com/GrassShrimp/ECK_demo/blob/master/kibana-dashboard.png)
get secretkey of apm server and modify secretToken of examples/express/kustomize/kustomization.yaml

```bash
$ kubectl get secret/apm-server-quickstart-apm-token -n elastic-system -o go-template='{{index .data "secret-token" | base64decode}}'
```

run demo app

```bash
$ cd examples/express && skaffold dev
```

![Elasctic APM](https://github.com/GrassShrimp/ECK_demo/blob/master/ECK_APM.png)