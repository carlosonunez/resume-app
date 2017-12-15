MAKEFLAGS += --silent
SHELL := /bin/bash
ifndef TRAVIS
	include .env
	export $(shell sed 's/=.*//' .env)
endif

# Shared build steps.
.PHONY: build init

build:
	if ! docker images | grep -q carlosonunez/ruby-rake-alpine; \
	then \
		docker build -f build_runner.Dockerfile -t "carlosonunez/ruby-rake-alpine:2.4.2" .; \
	fi

init: _bundle_install \
	_set_travis_env_vars

# Test build steps.
.PHONY: static_analysis unit_tests integration_tests

static_analysis: DOCKER_ACTIONS=bundle exec rake static_analysis:style
static_analysis: execute_static_analysis_checks_in_docker

unit_tests: USE_REAL_VALUES_FOR_TFVARS=false
unit_tests: DOCKER_ACTIONS=bundle exec rake unit:test
unit_tests: _generate_terraform_tfvars \
	execute_unit_test_in_docker \
	_delete_terraform_tfvars

# Terraform build steps.
.PHONY: _generate_terraform_tfvars _delete_terraform_tfvars
_generate_terraform_tfvars:
	echo "INFO: Generating Terraform variable values."; \
	if [ "$(USE_REAL_VALUES_FOR_TFVARS)" == "false" ]; \
	then \
		env_file=.env.example; \
		version=fake_version; \
	else \
		env_file=.env; \
		version=$$(cat version); \
	fi; \
	cat "$$env_file" | sed 's/\(.*\)=\(.*\)/\L\1="\2"/' > terraform.tfvars; \
	echo "app_version=\"$${version}\"" >> terraform.tfvars

_delete_terraform_tfvars:
	echo "INFO: Deleting Terraform variable values."; \
	rm terraform.tfvars

# Deployment and CI build steps.
# TODO: write cut over build step!
ifdef TRAVIS
.PHONY: integration_tests
integration_tests: DOCKER_ACTIONS=bundle exec rake integration:test
integration_tests: execute_integration_test_in_docker

.PHONY: version deploy deploy_docker_image
version: build init _bump_version_number _push_with_tags
deploy: build init deploy_docker_image
deploy_docker_image: _build_gem \
	_build_docker_image \
	_push_docker_image_to_docker_hub

# Gem and Docker image versioning build steps.
.PHONY: _push_with_tags
_push_with_tags: DOCKER_ACTIONS=git push --tags
_push_with_tags: execute_git_push_in_docker

.PHONY: _bump_version_number
_bump_version_number:
	if [ -z "$$TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	current_version_number=$$(cat version)
	current_major_version=$$(echo "$$current_version_number" | cut -f1 -d '.'); \
	todays_date=$$(date +%Y%m%d); \
	new_major_version="$$todays_date"; \
	if [ "$$current_major_version" == "$$todays_date" ]; \
	then \
		if [ ! -z "$$(echo "$$current_version_number" | grep '\.')" ]; \
		then \
			current_minor_version=$$(echo "$$current_version_number" | cut -f2 -d '.'); \
			new_minor_version="$$((current_minor_version+1))"; \
		else \
			new_minor_version=1; \
		fi; \
		new_version_number="$${new_major_version}.$${new_minor_version}"; \
	else \
		new_version_number="$${major_version}"; \
	fi; \
	if [ ! -z "$${new_version_number}" ]; \
	then \
		echo "INFO: Incrementing version: $${current_version_number} => $${new_version_number}"; \
		sed -i "s/VERSION = .*/VERSION = $${new_version_number}/" lib/resume_app/version.rb; \
		git commit -am "$$(git config --get author.email) | Automated version update." ; \
		git tag "$${new_version_number}"; \
	else \
		exit 1; \
	fi

# Build environment build steps.
.PHONY: _build_gem _build_docker_image

# Build our app artifact.
_build_gem: DOCKER_ACTIONS=gem build resume_app.gemspec
_build_gem: execute_gem_build_in_docker

# Place it into a Docker image.
_build_docker_image:
	current_version=$$(cat version)
	docker build -t "carlosonunez/resume_app:$$current_version" .

# Deploy it to Docker Hub.
.PHONY: _push_docker_image_to_docker_hub
_push_docker_image_to_docker_hub:
	if [ -z "$$TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	if ! docker login --username=$(DOCKER_HUB_USERNAME) --password=$(DOCKER_HUB_PASSWORD); \
	then \
		echo "ERROR: Failed to log into Docker Hub. Check your env vars."; \
		exit 1; \
	docker tag $$latest_image_id "carlosonunez/resume_app:latest"; \
	docker push "carlosonunez/resume_app"
endif

.PHONY: _bundle_install
_bundle_install: DOCKER_ACTIONS=bundle install --quiet
_bundle_install: execute_bundle_install_in_docker

.PHONY: _set_travis_env_vars _travis_login
_set_travis_env_vars:
	if [ ! -z "$$TRAVIS" ] || [ -z "$$UPDATE_TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	for env_var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION; \
	do \
		docker run --rm -i -e GEM_HOME=/root/.gem \
			-e $$env_var \
			-v $$PWD:/work \
			-v $$PWD/.gem:/root/.gem \
			-w /work \
			carlosonunez/ruby-rake-alpine:2.4.2 "travis login --github-token=$(TRAVIS_CI_GITHUB_TOKEN); \
				travis env set $$env_var $$$$env_var --private"; \
	done

.PHONY: execute_%_in_docker
execute_%_in_docker:
	docker run --rm -i -e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		-e AWS_DEFAULT_REGION=us-east-1 \
		-v $$PWD:/work \
		-v $$PWD/.gem:/root/.gem \
		-v $$HOME/.aws:/root/.aws \
		-w /work \
		-p 127.0.0.1:5000:5000 \
		carlosonunez/ruby-rake-alpine:2.4.2 "$(DOCKER_ACTIONS)"
