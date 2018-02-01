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
		app_version=fake_version; \
		lb_vpc_cidr_block=10.0.0.0/16; \
		lb_subnet_a_cidr_block=10.0.65.0/24; \
		lb_subnet_b_cidr_block=10.0.66.0/24; \
	else \
		env_file=.env; \
		app_version=$$(cat version); \
	fi; \
	cat "$$env_file" | sed 's/\(.*\)=\(.*\)/\L\1="\2"/' > terraform.tfvars; \
	echo "app_version=\"$${app_version}\"" >> terraform.tfvars

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
		rm -f terraform.tfplan.json; \
	fi; \
	docker run --rm -t -v $$PWD:/work -w /work \
		-v $$PWD/.go:/go \
		--entrypoint '/bin/sh' \
		$(GOLANG_DOCKER_IMAGE) -c 'if ! which tfjson > /dev/null; \
			then \
				echo -e "$(INFO): tfjson missing. Downloading it now."; \
				apk add --no-cache git; \
				go get $(TFJSON_GITHUB_URL); \
			fi; \
			tfjson terraform.tfplan >> terraform.tfplan.json';

_delete_terraform_tfvars:
	rm terraform.tfvars

_terraform_%: TERRAFORM_ACTION=$(shell echo "$@" | cut -f3 -d _)
_terraform_%:
	if [ "$(TERRAFORM_ACTION)" == "destroy" ]; \
	then \
		additional_actions="-force $(ADDITIONAL_TERRAFORM_ARGS)"; \
	else \
		additional_actions="$(ADDITIONAL_TERRAFORM_ARGS)"; \
	fi; \
	docker run -t -v $$PWD:/work -w /work \
		-v $$HOME/.aws:/root/.aws \
		--env-file .env \
		-e AWS_REGION \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
		hashicorp/terraform $(TERRAFORM_ACTION) $$additional_actions
