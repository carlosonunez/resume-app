#!/usr/bin/env make
TRAVIS_CLI_DOCKER_IMAGE=andredumas/travis-ci-cli:1.8.2
.PHONY: _set_travis_env_vars
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
			$(TRAVIS_CLI_DOCKER_IMAGE) "travis login \
				--github-token=$(TRAVIS_CI_GITHUB_TOKEN); \
				travis env set $$env_var $$$$env_var --private"; \
