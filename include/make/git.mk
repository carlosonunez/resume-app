#!/usr/bin/env make
ifndef VERSION_FILE
$(error You need to define VERSION_FILE first)
endif
ifndef TRAVIS_CI_GITHUB_TOKEN
$(error You need to define TRAVIS_CI_GITHUB_TOKEN first)
endif
GIT_UPSTREAM_URI=https://carlosonunez:$(TRAVIS_CI_GITHUB_TOKEN)@github.com/carlosonunez/resume-app.git

.PHONY: _push_with_tags
_push_with_tags: _add_upstream _push_changes

.PHONY: _add_upstream _push_changes
_add_upstream: GIT_OPTIONS=add origin-travis $(GIT_UPSTREAM_URI)
_add_upstream: _git_remote

_push_changes: GIT_OPTIONS=-u origin-travis master
_push_changes: _git_push

.PHONY: _git_%
_git_%: GIT_ACTION=$(shell echo "$@" | cut -f3 -d _)
_git_%:
	docker run -t -v $$PWD:/work -w /work \
		-e MAKE_IS_RUNNING=true \
		alpine/git $(GIT_ACTION) $(GIT_OPTIONS)
