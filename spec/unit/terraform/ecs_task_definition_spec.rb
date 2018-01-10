# frozen_string_literal: true

require 'spec_helper'

expected_serialized_container_definition =
  File.read('spec/unit/terraform/fixtures/container_definition.json')
      .tr("\n", '')
expected_container_definition =
  RSpecHelpers::JSONHelper.sort_objects_by_keys(
    JSON.parse(expected_serialized_container_definition)
  )
requirements = {
  family: {
    test_name: 'should have the correct family name',
    should_be: 'resume_app_service'
  },
  container_definitions: {
    test_name: 'should have the correct container definitions',
    json_should_be: expected_container_definition
  },
  requires_compatibilities: {
    test_name: 'It should be set to FARGATE',
    should_be: 'FARGATE'
  },
  cpu: {
    test_name: 'It should be greater than the minimum CPU units required',
    should_at_least_be: 512
  },
  memory: {
    test_name: 'It should be greater than the minimum memory MB required',
    should_at_most_be: 1024
  },
  network_mode: {
    test_name: 'It should be set to "awsvpc" so that Fargate will accept it',
    should_be: 'awsvpc'
  },
  task_role_arn: {
    test_name: 'It should refer to the IAM role that we create here',
    should_be: '${aws_iam_role.execution_and_task_role.arn}'
  },
  execution_role_arn: {
    test_name: 'It should refer to the IAM role that we create here',
    should_be: '${aws_iam_role.execution_and_task_role.arn}'
  }
}
RSpecHelpers::Terraform.run_tests(resource_name: 'aws_ecs_task_definition.task',
                                  tests: requirements)
