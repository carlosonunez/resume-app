require 'spec_helper'

describe 'Given a repository of Terraform configuration code',
         terraform: true do
  context 'When I define my ECS service' do
    it 'It should be called "resume_app"' do
      expect(@terraform_plan['aws_ecs_service.service']['name'])
        .to eq 'resume_app'
    end
  end
end
