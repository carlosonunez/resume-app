#!/usr/bin/env make
TRAVIS_CLI_DOCKER_IMAGE=caktux/travis-cli
.PHONY: _set_travis_env_vars
_set_travis_env_vars:
	docker run --rm -t -e GEM_HOME=/root/.gem \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		-v $$PWD:/work \
		-v $$PWD/.gem:/root/.gem \
		-w /work \
		--entrypoint /bin/sh \
		$(TRAVIS_CLI_DOCKER_IMAGE) -c 'travis login \
			--github-token=$(TRAVIS_CI_GITHUB_TOKEN); \
			printenv | \
			grep AWS | \
			sed -- "s/^\(AWS_.*\)=\(.*\)/travis env set \1 \2 --private/" | \
			while read command; do eval "$$command"; done'
