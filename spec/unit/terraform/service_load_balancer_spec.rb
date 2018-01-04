# frozen_string_literal: true

require 'spec_helper'
resources_and_requirements = {
  'aws_lb.lb' => {
    name: {
      test_name: 'It should have the correct load balancer name',
      should_be: 'resume-app-lb'
    },
    internal: {
      test_name: 'It should not be an internal load balancer',
      should_be: 'false'
    },
    load_balancer_type: {
      test_name: 'It should be an application load balancer',
      should_be: 'application'
    },
    enable_deletion_protection: {
      test_name: 'It should not have termination protection enabled',
      should_be: 'false'
    }
  },
  'aws_lb_target_group.target_group' => {
    name: {
      test_name: 'It should have the correct name',
      should_be: 'resume-app-lb-tg'
    },
    port: {
      test_name: 'It should be port 80',
      should_be: 4567
    },
    protocol: {
      test_name: 'It should be using HTTP',
      should_be: 'HTTP'
    },
    vpc_id: {
      test_name: 'It should be set to the correct VPC',
      should_be: ENV['LOAD_BALANCER_VPC']
    },
    'health_check.port': {
      test_name: 'It should be set to 4567',
      should_be: 4567
    },
    'health_check.protocol': {
      test_name: 'It should be set to HTTP',
      should_be: 'HTTP'
    }
  },
  'aws_lb_listener.listener' => {
    port: {
      test_name: 'It should be set to 80',
      should_be: 80
    },
    protocol: {
      test_name: 'It should be using HTTP',
      should_be: 'HTTP'
    },
    'default_action.target_group_arn': {
      test_name: 'It should be wired up to the appropriate target group',
      should_be: '${aws_lb_target_group.target_group.arn}'
    },
    'default_action.type': {
      test_name: 'It should forward packets',
      should_be: 'forward'
    },
    load_balancer_arn: {
      test_name: 'It should be set',
      should_be: '${aws_lb.lb.arn}'
    }
  }
}
resources_and_requirements.each do |resource, requirement|
  RSpecHelpers::Terraform.run_tests(resource_name: resource,
                                    test_definitions_hash: requirement)
end
