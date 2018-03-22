#!/usr/bin/env make
TRAVIS_CLI_DOCKER_IMAGE=caktux/travis-cli
TRAVIS_REPO=$(shell cat .git/config | \
						grep url | \
						sed 's;.*\:\(.*\).git;\1;' | \
						sed 's;\/;\\\/;')
.PHONY: _set_travis_env_vars
_set_travis_env_vars:
	docker run --rm -t \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION \
		-v $$PWD:/work \
		-w /work \
		--env-file .env \
		--entrypoint /bin/sh \
		$(TRAVIS_CLI_DOCKER_IMAGE) -c 'travis login --github-token=$(TRAVIS_CI_GITHUB_TOKEN); \
			(cat .env ; printenv | grep -E "AWS|DOCKER|TRAVIS|TERRAFORM") | \
			sort -u | \
			sed -- "s/^\(.*\)=\(.*\)/travis env set -r $(TRAVIS_REPO) \1 \2 --private/" | \
			while read command; do eval "$$command"; done'
