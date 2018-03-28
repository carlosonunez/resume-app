MAKEFLAGS += --silent
SHELL := /bin/bash
GEMSPEC_NAME = resume_app.gemspec
DOCKER_IMAGE_NAME = carlosnunez/resume_app
VERSION_FILE = version
APP_SPECIFIC_VERSION_FILE = lib/resume_app/version.rb
DOCKER_IMAGE_TAG = $(shell cat version)
ifneq ($(shell echo "$$UPDATE_ENVIRONMENT_VARIABLES"),)
UPDATE_ENVIRONMENT_VARIABLES = $(shell echo "$$UPDATE_ENVIRONMENT_VARIABLES")
else
UPDATE_ENVIRONMENT_VARIABLES = false
endif

include include/make/*.mk
include include/make/*/*.mk

local_build:
	$(MAKE) init && \
	$(MAKE) static_analysis && \
	$(MAKE) unit_tests && \
	$(MAKE) set_travis_env_vars
ci_build:
	$(MAKE) init && \
	$(MAKE) static_analysis && \
	$(MAKE) unit_tests && \
	$(MAKE) bump_the_version_number && \
	$(MAKE) publish_application && \
	$(MAKE) integration_setup && \
	$(MAKE) integration_tests && { \
		$(MAKE) integration_teardown; \
		echo "Tests passed."; \
	} || { \
		$(MAKE) integration_teardown; \
		echo "Tests failed."; \
	}

# Shared build steps.
.PHONY: stage_environment init

stage_environment: _ensure_environment_is_configured 

init: BUNDLE_OPTIONS=--quiet 
init: stage_environment \
	_bundle_install \
	_terraform_get \
	get_latest_commit_hash \
	verify_test_data_exists

.PHONY: static_analysis

static_analysis: BUNDLE_OPTIONS=rake static_analysis:style
static_analysis: stage_environment \
	_bundle_exec

.PHONY: unit_tests unit_setup unit_runner unit_teardown
unit_tests: unit_setup unit_runner unit_teardown

unit_setup: USE_REAL_VALUES_FOR_TFVARS=false
unit_setup: _generate_terraform_tfvars \
	_terraform_init_with_test_backend \
	_generate_test_terraform_plan \
	_generate_test_terraform_plan_json

unit_runner: BUNDLE_OPTIONS=rake unit:test
unit_runner: _bundle_exec

unit_teardown: _delete_terraform_tfvars

.PHONY: integration_tests \
	integration_setup \
	integration_teardown \
	integration_runner
integration_tests: integration_setup \
	integration_runner \
	integration_teardown
integration_setup: ADDITIONAL_TERRAFORM_ARGS=-auto-approve -input=false
integration_setup: _terraform_init_with_s3_backend \
	_generate_terraform_tfvars \
	_terraform_apply
ifndef TRAVIS
integration_teardown:
	echo "Since we've built this on a local box, integration will be kept up."; \
	exit 0
else
integration_teardown: _terraform_destroy
endif
integration_runner: BUNDLE_OPTIONS=rake integration:test
integration_runner: _bundle_exec

.PHONY: push_test_data
push_test_data: TEST_DATA_FILE=test_resume.md \
	TEST_DATA_SOURCE_LOCATION=spec/integration/fixtures \
	TEST_DATA_TARGET_DESTINATION=s3://$(S3_RESUME_BUCKET)/$(TEST_DATA_FILE) \
	TEST_DATA_LOCATION=$(S3_RESUME_BUCKET)/test \
	AWS_OPTIONS=cp $(TEST_DATA_SOURCE_LOCATION) $(TEST_DATA_TARGET_DESTINATION)
push_test_data: _aws_s3

.PHONY: publish_application
publish_application: stage_environment \
	_build_gem \
	_build_docker_image \
	_push_docker_image_to_docker_hub

.PHONY: deploy_app
deploy_app:
	echo "$(INFO) Working on it\!"; \
	exit 0
