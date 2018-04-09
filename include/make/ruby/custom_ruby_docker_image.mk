#!/usr/bin/make
_build_custom_ruby_docker_image:
	if [ ! -f ruby.Dockerfile ]; \
	then \
		echo -e "$(ERROR) You need to create a ruby.Dockerfile before using this Make target."; \
		exit 1; \
	fi; \
	docker build -t custom_ruby -f ruby.Dockerfile .
