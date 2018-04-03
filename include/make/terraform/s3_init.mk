#!/usr/bin/env make

.PHONY: _terraform_init_with_s3_backend
_terraform_init_with_s3_backend: \
	verify_environment_variable_TERRAFORM_STATE_S3_BUCKET \
	verify_environment_variable_TERRAFORM_STATE_S3_KEY \
	verify_environment_variable_AWS_REGION \
	verify_environment_variable_AWS_ACCESS_KEY_ID \
	verify_environment_variable_AWS_SECRET_ACCESS_KEY
ifdef ENVIRONMENT_ID
_terraform_init_with_s3_backend: \
	ADDITIONAL_TERRAFORM_ARGS = -backend-config "bucket=$(TERRAFORM_STATE_S3_BUCKET)" \
															-backend-config "key=$(TERRAFORM_STATE_S3_KEY)-$(BUILD_ENVIRONMENT)-$(ENVIRONMENT_ID)" \
															-backend-config "region=$(AWS_REGION)" \
															-reconfigure
else
_terraform_init_with_s3_backend: \
	ADDITIONAL_TERRAFORM_ARGS = -backend-config "bucket=$(TERRAFORM_STATE_S3_BUCKET)" \
															-backend-config "key=$(TERRAFORM_STATE_S3_KEY)-$(BUILD_ENVIRONMENT)" \
															-backend-config "region=$(AWS_REGION)" \
															-reconfigure
endif
_terraform_init_with_s3_backend: _terraform_init

.PHONY: _terraform_init_with_test_backend
_terraform_init_with_test_backend: \
	verify_environment_variable_TERRAFORM_STATE_S3_BUCKET \
	verify_environment_variable_TERRAFORM_STATE_S3_KEY \
	verify_environment_variable_AWS_REGION \
	verify_environment_variable_AWS_ACCESS_KEY_ID \
	verify_environment_variable_AWS_SECRET_ACCESS_KEY
_terraform_init_with_test_backend: \
	ADDITIONAL_TERRAFORM_ARGS = -backend-config "bucket=$(TERRAFORM_STATE_S3_BUCKET)" \
															-backend-config "key=test" \
															-backend-config "region=$(AWS_REGION)" \
															-reconfigure
_terraform_init_with_test_backend: _terraform_init
