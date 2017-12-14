require 'spec_helper'

describe 'Given a helper Rake library for executing Terraform tasks' do
  before(:all) do
    @test_terraform_config = <<-TERRAFORM
    TERRAFORM

    @expected_terraform_output = <<-TERRAFORM
    TERRAFORM

    @expected_exit_code = 0
  end

  context 'When we initialize Terraform' do
    it 'Should initialize successfully' do
    end
  end

  context 'When we plan our environment' do
    it 'Should generate a plan successfully' do
    end
  end

  context 'When we create our environment from an auto-generated plan' do
  
  context 'When we destroy our environment from an auto-generated plan' do
  end
end
