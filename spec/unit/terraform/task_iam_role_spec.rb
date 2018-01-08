# frozen_string_literal: true

RSpecHelpers::Terraform.run_tests(
  resource_name: 'aws_iam_role.execution_role',
  tests: {
    name: {
      test_name: 'It should be called "resume_app_task_execution_role"',
      should_be: 'resume_app_task_execution_role'
    },
    assume_role_policy: {
      test_name: 'It should have an IAM policy to enable AssumeRole on ECS.',
      json_should_be: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'sts:AssumeRole',
            Principal: {
              Service: 'ecs.amazonaws.com'
            },
            Effect: 'Allow',
            Sid: ''
          }
        ]
      }
    }
  }
)
