MAKEFLAGS += --silent
SHELL := /bin/bash

.PHONY: build init test deploy

build:
	docker build -t carlosonunez/ruby-rake-alpine:2.4.2

init: _bundle_install

test: DOCKER_ACTIONS="bundle exec rake test"
test: execute_rake_test_in_docker

deploy: DOCKER_ACTIONS="bundle exec rake deploy"
deploy: execute_rake_deploy_in_docker

.PHONY: _bundle_install
_bundle_install: DOCKER_ACTIONS="bundle install"
_bundle_install: execute_bundle_install_in_docker

.PHONY: execute_%_in_docker
execute_%_in_docker:
	docker run -d -e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		-v $$PWD:/work \
		-v $$PWD/.gem:/root/.gem \
		-p 127.0.0.1:5000:5000 \
		carlosonunez/ruby-rake-alpine:2.4.2 "$(DOCKER_ACTION)"
