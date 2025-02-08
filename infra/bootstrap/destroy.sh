#!/usr/bin/env bash
source ../.secrets.sh && \
source .out/.env && \
kubeone reset -m .out/kubeone.yaml -t .out/tf.json --remove-binaries --auto-approve && \
terraform destroy -auto-approve -input=false
