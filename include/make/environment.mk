#!/usr/bin/env make
.PHONY: _ensure_environment_is_configured
_ensure_environment_is_configured:
	cat .env.example | \
		cut -f1 -d '=' | \
		while read required_env_var; \
		do \
			if ! (env; cat .env) | grep -q "$$required_env_var"; \
			then \
				echo -e "$(ERROR): [$$required_env_var] is not configured in your \
environment. Please add it to your .env or Travis config."; \
				exit 1; \
			fi \
		done
