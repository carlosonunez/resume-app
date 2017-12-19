# frozen_string_literal: true

require 'spec_helper'

requirements = {
  name: {
    test_name: 'should be called "resume_app"',
    should_be: 'resume_app'
  },
  task_definition: {
    test_name: 'should point to the ARN of the "task" task definition',
    should_be: '${aws_ecs_task_definition.task.arn}'
  },
  desired_count: {
    test_name: 'should have the correct desired count',
    should_be: 3
  }
}
RSpecHelpers::Terraform.run_tests(resource_name: 'aws_ecs_service.service',
                                  requirements_hash: requirements)
