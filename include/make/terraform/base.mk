#/usr/bin/env make
GOLANG_DOCKER_IMAGE=golang:1.9-alpine3.7
TFJSON_GITHUB_URL=github.com/wybczu/tfjson

.PHONY: _generate_terraform_tfvars _delete_terraform_tfvars _terraform_%
_generate_terraform_tfvars: \
	verify_environment_variable_AWS_REGION \
	verify_environment_variable_AWS_ACCESS_KEY_ID \
	verify_environment_variable_AWS_SECRET_ACCESS_KEY
_generate_terraform_tfvars:
	if [ "$(USE_REAL_VALUES_FOR_TFVARS)" == "false" ]; \
	then \
		env_file=\".env.example\"; \
		environment=\"fake_env\"; \
		app_version=\"fake_version\"; \
	else \
		env_file=\".env.$(BUILD_ENVIRONMENT)\"; \
		environment=\"$(BUILD_ENVIRONMENT)\"; \
		app_version=\"$$(cat version)\"; \
	fi; \
	cat "$$env_file" | sed 's/\(.*\)=\(.*\)/\L\1="\2"/' > terraform.tfvars; \
	echo "environment=\"$${environment}\"" >> terraform.tfvars; \
	echo "app_version=\"$${app_version}\"" >> terraform.tfvars; \
	if [ "$(USE_REAL_VALUES_FOR_TFVARS)" == "false" ]; \
	then \
		echo "aws_access_key_id=\"fake\"" >> terraform.tfvars; \
		echo "aws_secret_access_key=\"fake\"" >> terraform.tfvars; \
		echo "aws_region=\"us-east-1\"" >> terraform.tfvars; \
	else \
		echo "aws_access_key_id=\"$$AWS_ACCESS_KEY_ID\"" >> terraform.tfvars; \
		echo "aws_secret_access_key=\"$$AWS_SECRET_ACCESS_KEY\"" >> terraform.tfvars; \
		echo "aws_region=\"$$AWS_REGION\"" >> terraform.tfvars; \
		echo -e "$(INFO) Terraform vars:" ; \
		cat terraform.tfvars; \
	fi	

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
_terraform_%: \
	verify_environment_variable_AWS_REGION \
	verify_environment_variable_AWS_ACCESS_KEY_ID \
	verify_environment_variable_AWS_SECRET_ACCESS_KEY
_terraform_%:
	if [ "$(TERRAFORM_ACTION)" == "destroy" ]; \
	then \
		additional_actions="-force $(ADDITIONAL_TERRAFORM_ARGS)"; \
	else \
		additional_actions="$(ADDITIONAL_TERRAFORM_ARGS)"; \
	fi; \
	if [ "$(TERRAFORM_ACTION)" == "plan" ] || \
		[ "$(TERRAFORM_ACTION)" == "apply" ]; \
	then \
		additional_actions="-input=false $(ADDITIONAL_TERRAFORM_ARGS)"; \
	else \
		additional_actions="$(ADDITIONAL_TERRAFORM_ARGS)"; \
	fi; \
	aws_default_region=$${AWS_DEFAULT_REGION:-$$AWS_REGION}; \
	docker run -it -v $$PWD:/work -w /work \
		-v $$HOME/.aws:/root/.aws \
		--env-file .env.$(BUILD_ENVIRONMENT) \
		-e AWS_REGION \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		-e AWS_DEFAULT_REGION=$$aws_default_region \
		hashicorp/terraform $(TERRAFORM_ACTION) $$additional_actions
