#!/bin/bash
echo "------------------------------------CERT-MANAGER------------------------------------"
namespace=$(kubectl get ns | grep "cert-manager" )
echo $namespace
if [[ -n $namespace  ]]
then
    echo "namespace cert-manager already exists"
else
    kubectl create ns cert-manager
fi

secret=$(kubectl get secret | grep "prod-cert-manager" )
if [[-n $secret ]]
then
echo "secret prod-cert-manager alreay exists"
else
kubectl create secret generic prod-cert-manager --from-file=credentials.json -n cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml



#####helm part####
output=$(helm version | grep "version.BuildInfo" )
if [[ -n $output ]]
then
    repo=$(helm repo list | grep jetstack)
else
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
fi

if [[ -n $repo  ]]
then
    echo "repo already exists"
else
    helm repo add jetstack https://charts.jetstack.io 
fi

cd cert-manager
helm repo update 
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager \
-f values.yaml \
--version v0.16.1 \
--debug \
--atomic \
--wait 

