#!/usr/bin/env make
.PHONY: get_latest_commit_hash
get_latest_commit_hash:
	GIT_OPTIONS="HEAD" $(MAKE) _git_rev-parse | head -c 8  > version; \
	echo "$(INFO) This repository is now at version $$(cat version)"

.PHONY: _git_%
_git_%: GIT_ACTION=$(shell echo "$@" | cut -f3 -d _)
_git_%:
	docker run -t -v $$PWD:/work -w /work \
		-e MAKE_IS_RUNNING=true \
		alpine/git $(GIT_ACTION) $(GIT_OPTIONS)
