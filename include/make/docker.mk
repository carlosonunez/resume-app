#!/usr/bin/env make
ifndef DOCKER_IMAGE_NAME
$(error You need to define a DOCKER_IMAGE_NAME, such as "$(USER)/foo".)
endif
ifndef DOCKER_HUB_USERNAME
$(error You need to define a DOCKER_HUB_USERNAME)
endif
ifndef DOCKER_HUB_PASSWORD
$(error You need to define a DOCKER_HUB_PASSWORD)
endif

.PHONY: _build_docker_image
_build_docker_image:
	app_version=$$(cat version); \
	if [ -z "$$app_version" ]; \
	then \
		echo -e "$(ERROR) App version not found. Was a 'version' file written?"; \
		exit 1; \
	fi; \
	docker build -t "$(DOCKER_IMAGE_NAME):$$app_version"

.PHONY: _push_docker_image_to_docker_hub
_push_docker_image_to_docker_hub:
	app_version=$$(cat version); \
	if [ -z "$$app_version" ]; \
	then \
		echo -e "$(ERROR) App version not found. Was a 'version' file written?"; \
		exit 1; \
	fi; \
	if ! docker login --username=$(DOCKER_HUB_USERNAME) --password=$(DOCKER_HUB_PASSWORD); \
	then \
		echo -e "$(ERROR): Failed to log into Docker Hub. Check your env vars."; \
		exit 1; \
	fi; \
	docker tag $$app_version $(DOCKER_IMAGE_NAME)
	docker push $(DOCKER_IMAGE_NAME)
