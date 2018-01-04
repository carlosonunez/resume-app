# frozen_string_literal: true

RSpecHelpers::Terraform.run_tests(
  resource_name: 'aws_cloudwatch_log_group.log',
  test_definitions_hash: {
    name: {
      test_name: 'It should have the right name',
      should_be: 'resume_app_logs'
    }
  }
)
