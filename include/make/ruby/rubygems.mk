#!/usr/bin/env make
RUBY_DOCKER_IMAGE := ruby:2.4-alpine3.7
ifndef GEMSPEC_NAME
	$(error Please define a GEMSPEC_NAME.)
endif
.PHONY: _build_gem
_build_gem:
	docker run --rm -it -v $$PWD:/work -w /work \
		-v $$PWD/.gem:/root/.gem \
		-e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		$(RUBY_DOCKER_IMAGE) gem build $(GEMSPEC_NAME)
