MAKEFLAGS += --silent
SHELL := /bin/bash
ifndef TRAVIS
	include .env
	export $(shell sed 's/=.*//' .env)
endif

# Shared build steps.
.PHONY: build init test

build:
	if ! docker images | grep -q carlosonunez/ruby-rake-alpine; \
	then \
		docker build -f build_runner.Dockerfile -t "carlosonunez/ruby-rake-alpine:2.4.2" . > /dev/null; \
	fi

init: _bundle_install _set_travis_env_vars
test: build init static_analysis unit_tests integration_tests

# Test build steps.
.PHONY: static_analysis unit_tests integration_tests

static_analysis: DOCKER_ACTIONS=bundle exec rake static_analysis:style
static_analysis: execute_static_analysis_checks_in_docker

unit_tests: DOCKER_ACTIONS=bundle exec rake unit:test
unit_tests: execute_unit_test_in_docker

integration_tests: DOCKER_ACTIONS=bundle exec rake integration:test
integration_tests: execute_integration_test_in_docker

# Deployment build steps.
ifdef TRAVIS
.PHONY: version deploy
version: build init _bump_version_number _push_with_tags
deploy: build init _build_gem _build_app _push_gem_to_docker_hub

.PHONY: _push_with_tags
_push_with_tags: DOCKER_ACTIONS=git push --tags
_push_with_tags: execute_git_push_in_docker

.PHONY: _bump_version_number
_bump_version_number:
	if [ -z "$$TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	current_version_number=$$(cat lib/resume_app/version.rb | \
												 grep VERSION | \
												 tr -d '" ' | \
												 cut -f2 -d =); \
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
.PHONY: _build_gem _build_app
_build_gem: DOCKER_ACTIONS=gem build resume_app.gemspec
_build_gem: execute_gem_build_in_docker

_build_app:
	version=$$(cat lib/resume_app/version.rb | \
					grep VERSION | \
					cut -f2 -d = | \
					tr -d '" '); \
	docker build -t "carlosonunez/resume_app:$$version" .

# Artifact deployment build step.
.PHONY: _push_gem_to_docker_hub
_push_gem_to_docker_hub:
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
		-v $$PWD:/work \
		-v $$PWD/.gem:/root/.gem \
		-v $$HOME/.aws:/root/.aws \
		-w /work \
		-p 127.0.0.1:5000:5000 \
		carlosonunez/ruby-rake-alpine:2.4.2 "$(DOCKER_ACTIONS)"
