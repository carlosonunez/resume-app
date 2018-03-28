#!/usr/bin/env make

.PHONY: push_test_data verify_test_data verify_that_resume_app_bucket_exists
verify_that_resume_app_bucket_exists:
	bucket_to_find="s3://$(S3_BUCKET_NAME)"; \
	if ! $$(AWS_OPTIONS="ls $$bucket_to_find" $(MAKE) _aws_s3 &> /dev/null); \
	then \
		echo -e "$(ERROR) Couldn't find or access [$$bucket_to_find]"; \
		exit 1; \
	fi
	
verify_that_test_data_is_present:
	test_file=spec/integration/fixtures/test_resumes/$(RESUME_NAME).md; \
	if [ ! -f "$$test_file"  ]; \
	then \
		echo -e "$(ERROR) Test file not found: $$test_file"; \
		exit 1; \
	fi
push_test_data: \
	AWS_OPTIONS=cp spec/integration/fixtures/test_resumes/$(RESUME_NAME).md \
		s3://$(S3_BUCKET_NAME)/$(RESUME_NAME)
push_test_data:	_aws_s3
