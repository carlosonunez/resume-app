require 'spec_helper'

describe 'Given a repository of Terraform configuration code',
         terraform: true do
  context 'When I define my ECS task definition' do
    it 'It should have an ECS task definition resource called "task"' do
      expect(@terraform_plan['aws_ecs_task_definition.task'])
        .not_to be nil
    end

    it 'It should have a family called "resume_app_service"' do
      expect(@terraform_plan['aws_ecs_task_definition.task']['family'])
        .to eq 'resume_app_service'
    end

    it 'It should be using "ecs_container_definition.json" for its ' \
       'container definition' do
      expected_serialized_container_definition =
        File.read('spec/unit/terraform/fixtures/container_definition.json')
            .tr("\n", '')
      expected_container_definition =
        RSpecHelpers::JSONHelper.sort_objects_by_keys(
          JSON.parse(expected_serialized_container_definition)
        )
      rendered_serialized_container_definition =
        @terraform_plan['aws_ecs_task_definition.task']['container_definitions']
      rendered_container_definition =
        JSON.parse(rendered_serialized_container_definition)
      expect(rendered_container_definition)
        .to eq expected_container_definition
    end
  end
end
