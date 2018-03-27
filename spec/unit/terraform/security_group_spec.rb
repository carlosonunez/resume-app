# frozen_string_literal: true

tests = [
  {
    resource_name: 'aws_security_group.lb_inbound',
    tests: {
      name: { should_be: 'resume_app_lb_inbound_sg' },
      description: {
        should_be: 'Allow inbound access to load balancer from the Internet.'
      },
      vpc_id: { should_be: '${aws_vpc.app.id}' },
      #      'ingress.from_port': { should_be: 80 },
      #      'ingress.to_port': { should_be: 80 },
      #      'ingress.protocol': { should_be: 'tcp' },
      #      'ingress.cidr_blocks': { should_be: ['0.0.0.0/0'] },
      #      'egress.from_port': { should_be: 0 },
      #      'egress.to_port': { should_be: 65_535 },
      #      'egress.protocol': { should_be: -1 },
      #      'egress.cidr_blocks': { should_be: ['0.0.0.0/0'] }
    }
  },
  {
    resource_name: 'aws_security_group.ecs_inbound',
    tests: {
      name: { should_be: 'resume_app_ecs_inbound_sg' },
      description: {
        should_be: 'Allow inbound access to ECS containers from load balancer.'
      },
      vpc_id: { should_be: '${aws_vpc.app.id}' },
      #      'ingress.from_port': { should_be: 4567 },
      #      'ingress.to_port': { should_be: 4567 },
      #      'ingress.protocol': { should_be: 'tcp' },
      #      'ingress.security_groups': {
      #        should_be: ['${aws_security_group.resume_app_lb_inbound_sg']
      #      },
      #      'ingress.cidr_blocks': { should_be: ['0.0.0.0/0'] },
      #      'egress.from_port': { should_be: 0 },
      #      'egress.to_port': { should_be: 65_535 },
      #      'egress.protocol': { should_be: -1 },
      #      'egress.cidr_blocks': { should_be: ['0.0.0.0/0'] }
    }
  }
]

tests.each do |test|
  RSpecHelpers::Terraform.run_tests(resource_name: test[:resource_name],
                                    tests: test[:tests])
end
