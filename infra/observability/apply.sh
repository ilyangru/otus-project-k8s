#!/usr/bin/env bash
export TF_VAR_bootstrap_state_s3_url=$SEL_S3_URL
export TF_VAR_bootstrap_state_s3_key=$SEL_S3_KEY
export TF_VAR_bootstrap_state_s3_bucket=$SEL_S3_BUCKET
export TF_VAR_bootstrap_state_s3_access_key=$SEL_S3_ACCESS_KEY
export TF_VAR_bootstrap_state_s3_secret_key=$SEL_S3_SECRET_KEY

# kubectl --namespace prometheus-operator --kubeconfig ../bootstrap/.out/k8s-project-kubeconfig get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

terraform init \
    -backend-config="endpoints={ s3 = \"https://$SEL_S3_URL\" }" \
    -backend-config="region=ru-1" \
    -backend-config="skip_region_validation=true" \
    -backend-config="skip_credentials_validation=true" \
    -backend-config="skip_requesting_account_id=true" \
    -backend-config="skip_s3_checksum=true" \
    -backend-config="skip_metadata_api_check=true" \
    -backend-config="bucket=$SEL_S3_BUCKET" \
    -backend-config="access_key=$SEL_S3_ACCESS_KEY" \
    -backend-config="secret_key=$SEL_S3_SECRET_KEY"

terraform plan && terraform apply -auto-approve -input=false