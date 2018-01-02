# frozen_string_literal: true

require 'spec_helper'
requirements = {
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
  },
  subnets: {
    test_name: 'It should be assigned to at least two subnets',
    array_size_should_at_least_be: 2
  }
}
RSpecHelpers::Terraform.run_tests(resource_name: 'aws_lb.lb',
                                  test_definitions_hash: requirements)
