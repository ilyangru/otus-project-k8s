#!/usr/bin/env bash
# Данные для доступа к хранилищу TF state
  export SEL_S3_URL=s3.ru-1.storage.selcloud.ru
  export SEL_S3_BUCKET=
  export SEL_S3_KEY=        # state filename, f.e. project.tfstate
  export SEL_S3_ACCESS_KEY=
  export SEL_S3_SECRET_KEY=
# администратор аккаунта и управления пользователями
 export TF_VAR_sel_admin_user=
 export TF_VAR_sel_admin_password=
 export TF_VAR_sel_account_id=