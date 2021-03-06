#!/bin/bash
echo "------------------------------------EXTERNAL-DNS------------------------------------"

output=$(helm version | grep "version.BuildInfo" )
if [[ -n $output ]]
then
    repo=$(helm repo list | grep bitnami)
else
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
fi


namespace=$(kubectl get ns | grep "external-dns" )
if [[ -n $namespace  ]]
then
    echo "namespace external-dns already exists"
else
    kubectl create ns external-dns
fi


secret=$(kubectl get secret | grep "external-dns" )
if [[-n $secret ]]
then
    echo "secret external-dns alreay exists"
else
    kubectl create secret generic external-dns --from-file=credentials.json -n external-dns
fi





if [[ -n $repo  ]]
then
    echo "repo already exists"
else
    helm repo add bitnami https://charts.bitnami.com/bitnami
fi
cd external-dns
helm repo update
helm upgrade --install external-dns bitnami/external-dns \
-n external-dns \
-f values.yaml \
--version 3.2.6 \
--atomic \
--wait 

