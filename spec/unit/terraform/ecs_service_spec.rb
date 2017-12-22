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
  },
  'load_balancer.elb_name': {
    test_name: 'It should have the correct name',
    should_be: 'resume_app_lb'
  },
  'load_balancer.container_name': {
    test_name: 'It should reference the correct container',
    should_be: 'resume_app'
  },
  'load_balancer.target_group_arn': {
    test_name: 'It should reference the correct load balancer ARN',
    should_be: '${aws_lb.lb.arn}'
  },
  'load_balancer.container_port': {
    test_name: 'It should associate with the correct port',
    should_be: '4567'
  },
  launch_type: {
    test_name: 'It should deploy into ECS Fargate',
    should_be: 'FARGATE'
  }
}
RSpecHelpers::Terraform.run_tests(resource_name: 'aws_ecs_service.service',
                                  requirements_hash: requirements)
