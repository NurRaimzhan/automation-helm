#!/bin/bash
echo "------------------------------------RELOADER------------------------------------"
namespace=$(kubectl get ns | grep "reloader" )
echo $namespace
if [[ -n $namespace  ]]
then
    echo "namespace ambassador already exists"
else
    kubectl create ns reloader
fi

#####helm part####
output=$(helm version | grep "version.BuildInfo" )
if [[ -n $output ]]
then
    repo=$(helm repo list | grep stakater)
else
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
fi

if [[ -n $repo  ]]
then
    echo "repo  already exists"
else
    helm repo add stakater https://stakater.github.io/stakater-charts 
fi

cd reloader
helm repo update 
helm upgrade --install reloader stakater/reloader \
-n reloader \
-f values.yaml \
--atomic \
--wait