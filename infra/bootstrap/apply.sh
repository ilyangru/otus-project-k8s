#!/usr/bin/env bash
source ../.secrets.sh && \
terraform apply -auto-approve -input=false && \
terraform output -json > .out/tf.json && \
cd .out && \
source .env && \
kubeone apply -t tf.json --auto-approve --create-machine-deployments=false --upgrade-machine-deployments=false #&& \
kubeone config machinedeployments -t tf.json > kubeone-machinedeployments.yaml #&& \
#kubectl apply -f kubeone-machinedeployments.yaml -n kube-system --kubeconfig k8s-project-kubeconfig

# kubectl taint nodes --all node.cloudprovider.kubernetes.io/uninitialized:NoSchedule-