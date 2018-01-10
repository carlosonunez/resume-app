# frozen_string_literal: true

RSpecHelpers::Terraform.run_tests(
  resource_name: 'aws_iam_role.execution_and_task_role',
  tests: {
    name: {
      test_name: 'It should have the correct name',
      should_be: 'ecsExecutionTaskRole'
    },
    assume_role_policy: {
      test_name: 'It should enable a trust relationship to ecs-tasks.',
      json_should_be: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'sts:AssumeRole',
            Principal: {
              Service: 'ecs-tasks.amazonaws.com'
            },
            Effect: 'Allow',
            Sid: ''
          }
        ]
      }
    }
  }
)

RSpecHelpers::Terraform.run_tests(
  resource_name: 'aws_iam_role_policy.execution_role_policy',
  tests: {
    name: {
      test_name: 'It should have the correct name',
      should_be: 'ecsExecutionRolePolicy'
    },
    role: {
      test_name: 'It should be mapped to the correct role',
      should_be: '${aws_iam_role.execution_and_task_role.id}'
    },
    policy: {
      test_name: 'It should allow access to AWS logs and CloudWatch',
      json_should_be: {
        Version: '2012-10-17',
        Statement: [
          Action: [
            'logs:*',
            'cloudwatch:*'
          ],
          Effect: 'Allow',
          Resource: '*'
        ]
      }
    }
  }
)
