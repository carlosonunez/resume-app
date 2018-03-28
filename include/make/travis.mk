#!/usr/bin/env make
TRAVIS_CLI_DOCKER_IMAGE=caktux/travis-cli
TRAVIS_REPO=$(shell cat .git/config | \
						grep url | \
						sed 's;.*\:\(.*\).git;\1;' | \
						sed 's;\/;\\\/;')
.PHONY: _set_travis_env_vars
set_travis_env_vars: verify_environment_variable_TRAVIS_CI_GITHUB_TOKEN
set_travis_env_vars:
	if [ "$(TRAVIS)" == "true" ] || \
		[ "$(UPDATE_ENVIRONMENT_VARIABLES)" == "false" ]; \
	then \
		echo -e "$(INFO) Skipping environment variables, as requested."; \
		exit 0; \
	fi; \
	docker run --rm -t \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		-v $$PWD:/work \
		-w /work \
		--env-file .env.$(BUILD_ENVIRONMENT) \
		--entrypoint /bin/sh \
		$(TRAVIS_CLI_DOCKER_IMAGE) -c '\
			travis login --github-token=$(TRAVIS_CI_GITHUB_TOKEN); \
			find .env.* | \
				grep -v .env.example | \
				while read env_file; \
				do \
					travis encrypt-file $$env_file --add; \
				done'
