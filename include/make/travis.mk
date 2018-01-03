#!/usr/bin/env make
TRAVIS_CLI_DOCKER_IMAGE=caktux/travis-cli
TRAVIS_REPO=$(shell cat .git/config | \
						grep url | \
						sed 's;.*\:\(.*\).git;\1;' | \
						sed 's;\/;\\\/;')
.PHONY: _set_travis_env_vars
_set_travis_env_vars:
	docker run --rm -t -e GEM_HOME=/root/.gem \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		-e TRAVIS_CI_GITHUB_TOKEN=$(TRAVIS_CI_GITHUB_TOKEN) \
		-e DOCKER_HUB_USERNAME=$(DOCKER_HUB_USERNAME) \
		-e DOCKER_HUB_PASSWORD=$(DOCKER_HUB_PASSWORD) \
		-v $$PWD:/work \
		-v $$PWD/.gem:/root/.gem \
		-w /work \
		--entrypoint /bin/sh \
		$(TRAVIS_CLI_DOCKER_IMAGE) -c 'gem list | grep ffi > /dev/null || apk add --update build-base libffi-dev; \
			gem list | grep travis > /dev/null || gem install travis; \
			travis login --github-token=$(TRAVIS_CI_GITHUB_TOKEN); \
			(printenv | grep -E "AWS|DOCKER|TRAVIS|TERRAFORM" ; cat .env) | \
			sed -- "s/^\(.*\)=\(.*\)/travis env set -r $(TRAVIS_REPO) \1 \2 --private/" | \
			while read command; do eval "$$command"; done'
