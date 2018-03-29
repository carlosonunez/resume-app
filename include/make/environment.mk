#!/usr/bin/env make
ifndef BUILD_ENVIRONMENT
$(error Please provide a BUILD_ENVIRONMENT)
endif

DOTENV_FILE = .env.$(BUILD_ENVIRONMENT)
ifeq (,$(wildcard $(DOTENV_FILE)))
$(error Please provide a .env for environment [$(BUILD_ENVIRONMENT)])
endif

include $(DOTENV_FILE)
export $(shell sed 's/=.*//' $(DOTENV_FILE))

.PHONY: _ensure_environment_is_configured
_ensure_environment_is_configured:
	cat .env.example | \
		cut -f1 -d '=' | \
		grep -Ev "^#" | \
		while read required_env_var; \
		do \
			if ! (env; cat $(DOTENV_FILE)) | grep -q "$$required_env_var"; \
			then \
				echo -e "$(ERROR): [$$required_env_var] is not configured in your \
environment. Please add it to your .env or Travis config."; \
				exit 1; \
			fi \
		done


.PHONY: verify_environment_variable_%
verify_environment_variable_%:
	@ if [ "${${*}}" == "" ]; \
		then \
			echo "Please define: $*"; \
			exit 1; \
		fi
