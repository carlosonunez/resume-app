#!/usr/bin/env make
RUBY_DOCKER_IMAGE := ruby:2.4-alpine3.7
.PHONY: _build_gem
_build_gem: verify_environment_variable_GEMSPEC_NAME
_build_gem:
	docker run --rm -it -v $$PWD:/work -w /work \
		-v $$PWD/.gem:/root/.gem \
		-e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		--env-file .env.$(BUILD_ENVIRONMENT) \
		--entrypoint /bin/sh \
		$(RUBY_DOCKER_IMAGE) -c "if [ ! -z "$(TRAVIS)" ]; \
			then \
				ls -lart; \
				source $$PWD/.env.$(BUILD_ENVIRONMENT); \
			fi; \
			gem build $(GEMSPEC_NAME)"
