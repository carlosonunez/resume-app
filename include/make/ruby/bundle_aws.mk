#!/usr/bin/env make
ifndef AWS_REGION
$(error AWS_REGION is not set.)
endif
ifndef AWS_ACCESS_KEY_ID
$(error AWS_ACCESS_KEY_ID is not set.)
endif
ifndef AWS_SECRET_ACCESS_KEY
$(error AWS_SECRET_ACCESS_KEY is not set.)
endif
.PHONY: _bundle_aws_%
_bundle_%: BUNDLE_ACTION=$(shell echo "$@" | cut -f3 -d _)
_bundle_%:
	docker run --rm -t -v $$PWD:/work -w /work \
		-v $$PWD/.gem:/root/.gem \
		-v $$HOME/.aws:/root/.aws \
		--env-file .env \
		-e GEM_HOME=/root/.gem \
		-e BUNDLE_PATH=/root/.gem \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		$(RUBY_DOCKER_IMAGE) bundle $(BUNDLE_ACTION) $(BUNDLE_OPTIONS)
