#!/usr/bin/env make
.PHONY: bump_the_version_number
bump_the_version_number: verify_environment_variable_APP_SPECIFIC_VERSION_FILE
bump_the_version_number:
	current_version_number=$$(cat $(APP_SPECIFIC_VERSION_FILE) | \
												 grep VERSION | \
												 sed "s#.*VERSION = '\([0-9\.]\+\)'.*#\1#"); \
	new_version_number=$$(date +%Y.%m.%d); \
	if [ "$$current_version_number" == "$$new_version_number" ]; \
	then \
		exit 0; \
	fi; \
	sed -i "s/VERSION = '$$current_version_number'/VERSION = '$$new_version_number'/" \
		$(APP_SPECIFIC_VERSION_FILE)
