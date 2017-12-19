#!/usr/bin/env make
ifndef TERRAFORM_STATE_S3_BUCKET
$(error Please define TERRAFORM_STATE_S3_BUCKET)
endif
ifndef TERRAFORM_STATE_S3_KEY
$(error Please define TERRAFORM_STATE_S3_KEY)
endif

.PHONY: _terraform_init_with_s3_backend
_terraform_init_with_s3_backend: \
	ADDITIONAL_TERRAFORM_ARGS = -backend-config "bucket=$(TERRAFORM_STATE_S3_BUCKET)" \
															-backend-config "key=$(TERRAFORM_STATE_S3_KEY)" \
															-backend-config "region=$(AWS_REGION)"
_terraform_init_with_s3_backend: _terraform_init
