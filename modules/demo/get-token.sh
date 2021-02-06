#!/bin/bash

while [ $(kubectl get secrets -n elastic-system apm-server-quickstart-apm-token --no-headers=true | wc -l) == 0 ]
do
  sleep 1;
done
kubectl get secret/apm-server-quickstart-apm-token -n elastic-system -o go-template='{{index .data "secret-token" | base64decode}}' | awk '{print "{\"token\":\""$1"\"}"}'