# frozen_string_literal: true

require 'spec_helper'

requirements = {
  name: {
    test_name: 'It should use a variable',
    should_be: 'change me'
  },
  type: {
    test_name: 'It should be an A record',
    should_be: 'A'
  },
  'alias.name': {
    test_name: "It should use the load balancer's DNS record",
    should_be: '${aws_lb.lb.dns_name}'
  },
  'alias.zone_id': {
    test_name: "It should use the load balancer's DNS zone ID",
    should_be: '${aws_lb.lb.zone_id}'
  },
  'alias.evaluate_target_health': {
    test_name: 'It should evaluate target health',
    should_be: true
  }
}

RSpecHelpers::Terraform.run_tests(resource_name: 'aws_route53_record.main',
                                  tests: requirements)
