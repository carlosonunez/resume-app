#/usr/bin/env make
GOLANG_DOCKER_IMAGE=golang:1.9-alpine3.7
TFJSON_GITHUB_URL=github.com/wybczu/tfjson

ifndef AWS_DEFAULT_REGION
AWS_DEFAULT_REGION = us-east-1
$(info AWS_DEFAULT_REGION was not set, so we are setting it to $(AWS_DEFAULT_REGION))
endif
ifndef AWS_REGION
$(error AWS_REGION is not set.)
endif
ifndef AWS_ACCESS_KEY_ID
$(error AWS_ACCESS_KEY_ID is not set.)
endif
ifndef AWS_SECRET_ACCESS_KEY
$(error AWS_SECRET_ACCESS_KEY is not set.)
endif

.PHONY: _generate_terraform_tfvars _delete_terraform_tfvars _terraform_%
_generate_terraform_tfvars:
	if [ "$(USE_REAL_VALUES_FOR_TFVARS)" == "false" ]; \
	then \
		env_file=.env.example; \
		version=fake_version; \
	else \
		env_file=.env; \
		version=$$(cat version); \
	fi; \
	cat "$$env_file" | sed 's/\(.*\)=\(.*\)/\L\1="\2"/' > terraform.tfvars; \
	echo "app_version=\"$${version}\"" >> terraform.tfvars

.PHONY: _generate_test_terraform_plan
_generate_test_terraform_plan: ADDITIONAL_TERRAFORM_ARGS=\
	-state=dummy \
	-out=terraform.tfplan
_generate_test_terraform_plan: _terraform_plan


.PHONY: _generate_test_terraform_plan_json
_generate_test_terraform_plan_json:
	$(info Converting test Terraform plan to JSON. Please wait a moment.)
	if [ -f terraform.tfplan.json ]; \
	then \
		exit 0; \
	fi; \
	docker run --rm -t -v $$PWD:/work -w /work \
		--entrypoint '/bin/sh' \
		$(GOLANG_DOCKER_IMAGE) -c "apk upgrade > /dev/null && \
			apk add --no-cache git > /dev/null && \
			go get $(TFJSON_GITHUB_URL) && \
			tfjson terraform.tfplan >> terraform.tfplan.json";

_delete_terraform_tfvars:
	rm terraform.tfvars

_terraform_%: TERRAFORM_ACTION=$(shell echo "$@" | cut -f3 -d _)
_terraform_%:
	docker run -t -v $$PWD:/work -w /work \
		-v $$HOME/.aws:/root/.aws \
		-e AWS_REGION \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		hashicorp/terraform $(TERRAFORM_ACTION) $(ADDITIONAL_TERRAFORM_ARGS)
