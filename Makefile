MAKEFLAGS += --silent
SHELL := /bin/bash
GEMSPEC_NAME = resume_app.gemspec
DOCKER_IMAGE_NAME = carlosonunez/resume_app
VERSION_FILE = version
DOCKER_IMAGE_TAG = $(shell cat version)

ifndef TRAVIS
include .env
export $(shell sed 's/=.*//' .env)
TERRAFORM_STATE_ENVIRONMENT = $(shell echo local_$$USER_$$(date +%Y%m%d.%H%M%S))
else
ifndef TERRAFORM_STATE_ENVIRONMENT
TERRAFORM_STATE_ENVIRONMENT = integration
endif
endif

include include/make/*.mk
include include/make/*/*.mk

# Shared build steps.
.PHONY: validate_environment init

validate_environment: _ensure_environment_is_configured

init: BUNDLE_OPTIONS=--quiet 
init: validate_environment \
	_bundle_install \
	_terraform_init_with_s3_backend \
	_terraform_get \
	get_latest_commit_hash

local_build:
	$(MAKE) init; \
	$(MAKE) static_analysis; \
	$(MAKE) unit_tests; \
	$(MAKE) _set_travis_env_vars
ci_build: init static_analysis unit_tests deploy_image integration_tests

# Test build steps.
.PHONY: static_analysis unit_tests integration_tests

static_analysis: BUNDLE_OPTIONS=rake static_analysis:style
static_analysis: validate_environment \
	_bundle_exec

unit_tests: USE_REAL_VALUES_FOR_TFVARS=false
unit_tests: BUNDLE_OPTIONS=rake unit:test
unit_tests: validate_environment \
	_generate_terraform_tfvars \
	_generate_test_terraform_plan \
	_generate_test_terraform_plan_json \
	_bundle_exec \
	_delete_terraform_tfvars

.PHONY: deploy_image
deploy_image: validate_environment \
	_build_gem \
	_build_docker_image \
	_push_docker_image_to_docker_hub

.PHONY: deploy_app
deploy_app:
	echo "$(INFO) Working on it\!"; \
	exit 0

.PHONY: integration_tests integration_setup integration_teardown
integration_setup: ADDITIONAL_TERRAFORM_ARGS=-auto-approve -input=false
integration_setup: validate_environment \
	_generate_terraform_tfvars \
	_terraform_apply
integration_teardown: _terraform_destroy
integration_tests: BUNDLE_OPTIONS=rake integration:test
integration_tests: integration_setup _bundle_exec integration_teardown
