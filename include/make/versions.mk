#!/usr/bin/env make
.PHONY: _bump_version_number
_bump_version_number:
	if [ -z "$$TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	current_version_number=$$(cat version)
	current_major_version=$$(echo "$$current_version_number" | cut -f1 -d '.'); \
	todays_date=$$(date +%Y%m%d); \
	new_major_version="$$todays_date"; \
	if [ "$$current_major_version" == "$$todays_date" ]; \
	then \
		if [ ! -z "$$(echo "$$current_version_number" | grep '\.')" ]; \
		then \
			current_minor_version=$$(echo "$$current_version_number" | cut -f2 -d '.'); \
			new_minor_version="$$((current_minor_version+1))"; \
		else \
			new_minor_version=1; \
		fi; \
		new_version_number="$${new_major_version}.$${new_minor_version}"; \
	else \
		new_version_number="$${major_version}"; \
	fi; \
	if [ ! -z "$${new_version_number}" ]; \
	then \
		echo "INFO: Incrementing version: $${current_version_number} => $${new_version_number}"; \
		sed -i "s/VERSION = .*/VERSION = $${new_version_number}/" lib/resume_app/version.rb; \
		git commit -am "$$(git config --get author.email) | Automated version update." ; \
		git tag "$${new_version_number}"; \
	else \
		exit 1; \
	fi

