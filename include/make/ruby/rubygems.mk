#!/usr/bin/env make
RUBY_DOCKER_IMAGE := ruby:2.4-alpine3.7
.PHONY: _build_gem
_build_gem: verify_environment_variable_GEMSPEC_NAME
_build_gem:
	if [ -f ruby.Dockerfile ]; \
	then \
		ruby_docker_image=custom_ruby; \
	else \
		ruby_docker_image=$(RUBY_DOCKER_IMAGE); \
	fi; \
	docker run --rm -it -v $$PWD:/work -w /work \
		-v $$PWD/.gem:/root/.gem \
		-e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		--env-file .env.$(BUILD_ENVIRONMENT) \
		"$$ruby_docker_image" gem build $(GEMSPEC_NAME)
