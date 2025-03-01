#!/usr/bin/env bash
export TF_VAR_bootstrap_state_s3_url=$SEL_S3_URL
export TF_VAR_bootstrap_state_s3_key=$SEL_S3_KEY
export TF_VAR_bootstrap_state_s3_bucket=$SEL_S3_BUCKET
export TF_VAR_bootstrap_state_s3_access_key=$SEL_S3_ACCESS_KEY
export TF_VAR_bootstrap_state_s3_secret_key=$SEL_S3_SECRET_KEY

terraform destroy -auto-approve -input=false