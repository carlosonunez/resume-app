MAKEFLAGS += --silent
SHELL := /bin/bash
GEMSPEC_NAME = resume_app.gemspec
DOCKER_IMAGE_NAME = carlosonunez/resume_app
DOCKER_IMAGE_TAG = $(shell cat version)
DOCKER_HUB_USERNAME = $(shell cat .env | \
											grep DOCKER_HUB_USERNAME | \
											cut -f2 -d =)
DOCKER_HUB_PASSWORD = $(shell cat .env | \
											grep DOCKER_HUB_PASSWORD | \
											cut -f2 -d =)
TRAVIS_CI_GITHUB_TOKEN = $(shell cat .env | \
											grep TRAVIS_CI_GITHUB_TOKEN | \
											cut -f2 -d =)

ifndef TRAVIS
	include .env
	export $(shell sed 's/=.*//' .env)
endif
include include/make/*.mk
include include/make/*/*.mk

# Shared build steps.
.PHONY: init

init: _bundle_install \
	_set_travis_env_vars \
	_terraform_init \
	_terraform_get

# Test build steps.
.PHONY: static_analysis unit_tests integration_tests

static_analysis: BUNDLE_ACTIONS=rake static_analysis:style
static_analysis: _bundle_exec

unit_tests: USE_REAL_VALUES_FOR_TFVARS=false
unit_tests: BUNDLE_ACTIONS=rake unit:test
unit_tests: _generate_terraform_tfvars \
	_generate_test_terraform_plan \
	_generate_test_terraform_plan_json \
	_bundle_exec \
	_delete_terraform_tfvars

# Deployment and CI build steps.
# TODO: write cut over build step!
ifdef TRAVIS
.PHONY: integration_tests
integration_tests: BUNDLE_ACTIONS=rake integration:test
integration_tests: _bundle_exec

.PHONY: version deploy deploy_docker_image
version: build init _bump_version_number _push_with_tags
deploy: build init deploy_docker_image
deploy_docker_image: _build_gem \
	_build_docker_image \
	_push_docker_image_to_docker_hub
endif
