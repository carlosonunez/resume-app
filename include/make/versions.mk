#!/usr/bin/env make
ifndef VERSION_FILE
$(error You need to define VERSION_FILE first)
endif

TRAVIS_GIT_ORIGIN_URI=https://carlosonunez:$(TRAVIS_CI_GITHUB_TOKEN)@github.com/carlosonunez/resume-app.git

.PHONY: _bump_version_number
_bump_version_number:
	if [ -z "$$TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	current_version_number=$$(cat $(VERSION_FILE)); \
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
		new_version_number="$${new_major_version}"; \
	fi; \
	if [ ! -z "$${new_version_number}" ]; \
	then \
		echo -e "$(INFO): Incrementing version: $${current_version_number} => $${new_version_number}"; \
		echo "$${new_version_number}" > $(VERSION_FILE); \
		git commit -am "Automated version update."; \
		git tag -f "$$(cat $(VERSION_FILE))"; \
		git remote add origin-travis $(TRAVIS_GIT_ORIGIN_URI); \
		MAKE_IS_RUNNING=true git push -u origin-travis master --tags; \
		git remote remove origin-travis; \
	else \
		exit 1; \
	fi
