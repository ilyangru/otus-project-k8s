#!/usr/bin/env bash
terraform init \
    -backend-config="endpoints={ s3 = \"https://s3.ru-1.storage.selcloud.ru\" }" \
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