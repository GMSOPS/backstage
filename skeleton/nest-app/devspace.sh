#!/bin/bash

msg="./devspace.sh up <kubeconfig path> <developer-name> <database-password> or ./devspace.sh down <kubeconfig path> <developer-name>"

if [[ "$1" != "up" && "$1" != "down" ]]; then
    echo $msg
    exit 1
fi

if [[ "$1" = "down" && "$#" -ne 3 ]]; then
    echo $msg
    exit 1
fi

if [[ "$1" = "up" && "$#" -ne 4 ]]; then
    echo $msg
    exit 1
fi

export KUBECONFIG=$2
dev=$3


if [ $1 = "down" ]; then
    helm uninstall -n ${{values.app}} ${{values.app}}-$dev
    helm uninstall -n ${{values.app}} $dev
    kubectl get replicaset -n ${{values.app}} -o name | grep $dev | xargs kubectl delete -n ${{values.app}}
    echo "Cleanup successful"
    exit 0
fi

releases=$(helm list -n ${{values.app}})

if [[ $releases == *"$dev"* ]]; then
  devspace dev --var=DEV=$dev --var=APP=${{values.app}} --var=PORT=${{values.port}} --var=DEVSPACE_IMAGE=${{values.registry}}/${{values.app}}/${{values.app}}-devspace:latest
else
  password=$4
  helm_username=$(kubectl get secrets -n ${{values.app}} helm-pull-secret -o jsonpath={.data.username} | base64 -d)
  helm_password=$(kubectl get secrets -n ${{values.app}} helm-pull-secret -o jsonpath={.data.password} | base64 -d)
  helm install -n ${{values.app}} $dev --repo=https://harbor.mgmt.neotechsolutions.org/chartrepo/utilities/ ebanking-dev-environment --set password=$password --set postgresql.auth.existingSecret=ebanking-$dev --username $helm_username --password $helm_password
  devspace dev --var=DEV=$dev --var=APP=${{values.app}} --var=PORT=${{values.port}} --var=DEVSPACE_IMAGE=${{values.registry}}/${{values.app}}/${{values.app}}-devspace:latest
fi