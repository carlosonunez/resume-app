#!/usr/bin/env make
.PHONY: _aws_%
_aws_%: \
	_verify_environment_variable_AWS_REGION \
	_verify_environment_variable_AWS_ACCESS_KEY_ID \
	_verify_environment_variable_AWS_SECRET_ACCESS_KEY \
_aws_%: AWS_ACTION=$(shell echo "$@" | cut -f3 -d _)
_aws_%:
	docker run -t -v $$PWD:/work -w /work \
		-e AWS_REGION \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		anigeo/awscli $(AWS_ACTION) $(AWS_OPTIONS)
