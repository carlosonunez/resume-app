#!/usr/bin/env make
ifndef DOCKER_IMAGE_NAME
$(error You need to define a DOCKER_IMAGE_NAME, such as "$(USER)/foo".)
endif
ifndef DOCKER_IMAGE_TAG
$(info Since you did not define DOCKER_IMAGE_TAG, we will use "latest".)
endif
ifndef DOCKER_HUB_USERNAME
$(error You need to define a DOCKER_HUB_USERNAME)
endif
ifndef DOCKER_HUB_PASSWORD
$(error You need to define a DOCKER_HUB_PASSWORD)
endif
ifndef DOCKER_IMAGE_TAG
$(info Since you did not define DOCKER_IMAGE_TAG, we will use "latest".)
DOCKER_IMAGE_TAG := latest
endif

.PHONY: _build_docker_image
_build_docker_image:
	docker build -t "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)"

.PHONY: _push_docker_image_to_docker_hub
_push_docker_image_to_docker_hub:
	if [ -z "$$TRAVIS" ]; \
	then \
		exit 0; \
	fi; \
	if ! docker login --username=$(DOCKER_HUB_USERNAME) --password=$(DOCKER_HUB_PASSWORD); \
	then \
		echo -e "$(ERROR): Failed to log into Docker Hub. Check your env vars."; \
		exit 1; \
	fi; \
	docker tag $(DOCKER_IMAGE_TAG) $(DOCKER_IMAGE_NAME)
	docker push $(DOCKER_IMAGE_NAME)
