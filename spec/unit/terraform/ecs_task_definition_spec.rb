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
    should_be: expected_container_definition,
    matcher_type: :json
  },
  requires_compatibilities: {
    test_name: 'It should be set to FARGATE',
    should_be: 'FARGATE'
  },
  cpu: {
    test_name: 'It should be greater than the minimum CPU units required',
    should_at_least_be: 0.5
  },
  memory: {
    test_name: 'It should be greater than the minimum memory MB required',
    should_at_most_be: 128
  }
}
RSpecHelpers::Terraform.run_tests(resource_name: 'aws_ecs_task_definition.task',
                                  test_definitions_hash: requirements)
