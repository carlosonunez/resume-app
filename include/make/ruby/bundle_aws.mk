#!/usr/bin/env make
.PHONY: _bundle_aws_%
_bundle_%: BUNDLE_ACTION=$(shell echo "$@" | cut -f3 -d _)
_bundle_%: \
	verify_environment_variable_AWS_ACCESS_KEY_ID \
	verify_environment_variable_AWS_SECRET_ACCESS_KEY \
	verify_environment_variable_AWS_REGION
_bundle_%:
	if docker images custom_ruby > /dev/null; \
	then \
		ruby_docker_image=custom_ruby; \
	else \
		ruby_docker_image=$(RUBY_DOCKER_IMAGE); \
	fi; \
	docker run --rm -t -v $$PWD:/work -w /work \
		-v $$PWD/.gem:/root/.gem \
		-v $$HOME/.aws:/root/.aws \
		--env-file .env.$(BUILD_ENVIRONMENT) \
		-e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		"$$ruby_docker_image" bundle $(BUNDLE_ACTION) $(BUNDLE_OPTIONS)
