#!/usr/bin/env make
.PHONY: _push_with_tags
_push_with_tags:
	docker run --rm -it -v $$PWD:/work -w /work alpine/git push --tags
