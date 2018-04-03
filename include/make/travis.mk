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
			files_to_encrypt=$$(\
				find .env.* \
					-not -name *.enc \
					-not -name .env.example | \
				tr "\n" " " \
			) &&  \
			tar cvf env.tar $$files_to_encrypt && \
			travis login --github-token=$(TRAVIS_CI_GITHUB_TOKEN) && \
			travis encrypt-file env.tar --add --force && rm env.tar && \
			travis env set -r $(TRAVIS_REPO) AWS_ACCESS_KEY_ID $$AWS_ACCESS_KEY_ID && \
			travis env set -r $(TRAVIS_REPO) AWS_REGION $$AWS_REGION && \
			travis env set -r $(TRAVIS_REPO) AWS_SECRET_ACCESS_KEY $$AWS_SECRET_ACCESS_KEY'
