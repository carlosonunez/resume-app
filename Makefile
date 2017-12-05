MAKEFLAGS += --silent
SHELL := /bin/bash
ifndef TRAVIS
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: build init test deploy

build:
	if ! docker images | grep -q carlosonunez/ruby-rake-alpine; \
	then \
		docker build -f build_runner.Dockerfile -t "carlosonunez/ruby-rake-alpine:2.4.2" . > /dev/null; \
	fi

init: _bundle_install _set_travis_env_vars

test: DOCKER_ACTIONS=bundle exec rake test
test: build init execute_rake_test_in_docker

deploy: build init _build_gem _build_app _push_gem_to_docker_hub

.PHONY: _build_gem _build_app
_build_gem: DOCKER_ACTIONS=gem build resume_app.gemspec
_build_gem: execute_gem_build_in_docker

_build_app:
	version=$$(cat lib/resume_app/version.rb | \
					grep version_id | \
					cut -f2 -d =); \
	docker build -t "carlosonunez/resume_app:$$version" .

.PHONY: _push_gem_to_docker_hub
_push_gem_to_docker_hub:
	if ! docker login --username=$(DOCKER_HUB_USERNAME) --password=$(DOCKER_HUB_PASSWORD); \
	then \
		echo "ERROR: Failed to log into Docker Hub. Check your env vars."; \
		exit 1; \
	fi; \
	latest_image_id=$$(docker images | grep resume_app | awk '{print $$3}'); \
	docker tag $$latest_image_id "carlosonunez/resume_app:latest"; \
	docker push "carlosonunez/resume_app"

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
