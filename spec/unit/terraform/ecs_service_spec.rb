# frozen_string_literal: true

require 'spec_helper'

describe 'Given a repository of Terraform configuration code',
         terraform: true do
  context 'When I define my ECS service' do
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
    requirements.each_key do |requirement|
      test_name = requirements[requirement][:test_name]
      expected_value = requirements[requirement][:should_be]
      it "It #{test_name}" do
        actual_value =
          @terraform_plan['aws_ecs_service.service'][requirement.to_s]
        expect(actual_value).to eq expected_value
      end
    end
  end
end
