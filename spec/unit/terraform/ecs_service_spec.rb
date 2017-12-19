require 'spec_helper'

describe 'Given a repository of Terraform configuration code',
         terraform: true do
  context 'When I define my ECS service' do
    requirements = {
      :name: {
        'test_name': 'Should be called "resume_app"',
        'should_be': 'resume_app'
      },
      :task_definition: {
        'test_name': 'Should point to the ARN of the "task" task definition',
        'should_be': '${aws_ecs_task_definition.task.arn}'
      },
      :desired_count: {
        'test_name': 'Should have the correct desired count',
        'should_be': 3
      }
    }
    requirements.each_key do |requirement_sym|
      requirement = requirement_sym.to_s
      test_name = requirements[requirement]['test_name']
      expected_value = requirements[requirement]['should_be']
      actual_value = @terraform_plan["aws_ecs_service.service"][requirement]
      it "It #{test_name}" do
        expect(actual_value).to eq expected_value
      end
    end
  end
end
