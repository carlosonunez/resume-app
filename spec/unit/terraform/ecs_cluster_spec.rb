# frozen_string_literal: true

requirements = {
  name: {
    test_name: 'It should have a name',
    should_be: 'resume_app_ecs_cluster-fake'
  }
}
RSpecHelpers::Terraform.run_tests(resource_name: 'aws_ecs_cluster.cluster',
                                  tests: requirements)
