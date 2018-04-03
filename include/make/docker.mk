#!/usr/bin/env make
.PHONY: _build_docker_image
_build_docker_image: verify_environment_variable_DOCKER_IMAGE_NAME
_build_docker_image:
	app=$$(echo "$(DOCKER_IMAGE_NAME)" | cut -f2 -d /); \
	app_version=$$(cat version); \
	if [ -z "$$app_version" ] || [ -z "$$app" ]; \
	then \
		echo -e "$(ERROR) App or app version not found. Was a 'version' file written?"; \
		exit 1; \
	fi; \
	echo "Bundling $$app with version $$app_version"; \
	docker build -t "$$app:$$app_version" \
		--build-arg GEM_AUTHOR=$(GEM_AUTHOR) \
		--build-arg GEM_EMAIL=$(GEM_EMAIL) \
		.

.PHONY: _push_docker_image_to_docker_hub
_push_docker_image_to_docker_hub: \
	verify_environment_variable_DOCKER_IMAGE_NAME \
	verify_environment_variable_DOCKER_HUB_USERNAME \
	verify_environment_variable_DOCKER_HUB_PASSWORD
_push_docker_image_to_docker_hub:
	app=$$(echo "$(DOCKER_IMAGE_NAME)" | cut -f2 -d /); \
	app_version=$$(cat version); \
	if [ -z "$$app_version" ] || [ -z "$$app" ]; \
	then \
		echo -e "$(ERROR) App or app version not found. Was a 'version' file written?"; \
		exit 1; \
	fi; \
	if ! docker login --username=$(DOCKER_HUB_USERNAME) --password=$(DOCKER_HUB_PASSWORD); \
	then \
		echo -e "$(ERROR): Failed to log into Docker Hub. Check your env vars."; \
		exit 1; \
	fi; \
	echo "Pushing $$app to $(DOCKER_IMAGE_NAME) with tag $$app_version"; \
	docker tag $$app:$$app_version $(DOCKER_IMAGE_NAME):$$app_version; \
	docker push $(DOCKER_IMAGE_NAME):$$app_version
