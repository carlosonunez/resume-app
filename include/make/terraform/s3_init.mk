#!/usr/bin/env make
ifndef TERRAFORM_STATE_S3_BUCKET
$(error Please define TERRAFORM_STATE_S3_BUCKET)
endif
ifndef TERRAFORM_STATE_S3_KEY
$(error Please define TERRAFORM_STATE_S3_KEY)
endif
ifndef TERRAFORM_STATE_ENVIRONMENT
$(error Please define the environment to store your infrastructure state in.)
endif

.PHONY: _terraform_init_with_s3_backend
_terraform_init_with_s3_backend: \
	ADDITIONAL_TERRAFORM_ARGS = -backend-config "bucket=$(TERRAFORM_STATE_S3_BUCKET)" \
															-backend-config "key=$(TERRAFORM_STATE_S3_KEY)-$(TERRAFORM_STATE_ENVIRONMENT)" \
															-backend-config "region=$(AWS_REGION)" \
															-reconfigure
_terraform_init_with_s3_backend: _terraform_init

.PHONY: _terraform_init_with_test_backend
_terraform_init_with_test_backend: \
	ADDITIONAL_TERRAFORM_ARGS = -backend-config "bucket=$(TERRAFORM_STATE_S3_BUCKET)" \
															-backend-config "key=test" \
															-backend-config "region=$(AWS_REGION)" \
															-reconfigure
_terraform_init_with_test_backend: _terraform_init
