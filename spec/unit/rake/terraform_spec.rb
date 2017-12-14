require 'spec_helper'
require_relative '../../../lib/rake/helpers/terraform.rb'

describe 'Given a helper Rake library for executing Terraform tasks' do
  let(:stubbed_shell) { create_stubbed_env }
  let!(:stubbed_terraform) { stubbed_shell.stub_command('terraform') }
  before(:all) do
    @test_terraform_config = <<-TERRAFORM
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/8"
}
    TERRAFORM

    @test_terraform_output = <<-TERRAFORM
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_vpc.my_vpc
      id:                               <computed>
      assign_generated_ipv6_cidr_block: "false"
      cidr_block:                       "10.0.0.0/8"
      default_network_acl_id:           <computed>
      default_route_table_id:           <computed>
      default_security_group_id:        <computed>
      dhcp_options_id:                  <computed>
      enable_classiclink:               <computed>
      enable_classiclink_dns_support:   <computed>
      enable_dns_hostnames:             <computed>
      enable_dns_support:               "true"
      instance_tenancy:                 <computed>
      ipv6_association_id:              <computed>
      ipv6_cidr_block:                  <computed>
      main_route_table_id:              <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
    TERRAFORM

    @expected_exit_code = 0
  end

  context 'When we initialize Terraform' do
    %w[init get].each do |terraform_action|
      it "It should perform `terraform #{terraform_action}`" do
        expect(RakeHelpers::Terraform.initialize!).to be nil
        expect(stubbed_terraform.with_args(terraform_action)).to be_called
      end

      it "It should error when `terraform #{terraform_action}` fails" do
        stubbed_terraform.with_args(terraform_action).returns_exitstatus(1)
        expect { RakeHelpers::Terraform.initialize! }
          .to raise_error("Terraform failed to #{terraform_action}.")
      end
    end
  end

  context 'When we plan our environment' do
    it 'It should generate a plan successfully' do
      stubbed_terraform.with_args('plan').outputs(
        @test_terraform_output, to: :stdout
      )
      expect(RakeHelpers::Terraform.plan_valid?).to be true
    end
  end

  context 'When we create our environment from an auto-generated plan' do
    it 'It should perform `terraform apply` successfully' do
      expect(RakeHelpers::Terraform.create_environment!).to be nil
      expect(stubbed_terraform.with_args('apply')).to be_called
    end

    it "It should error when the environment couldn't be created" do
      stubbed_terraform.with_args('apply').returns_exitstatus(1)
      expect { RakeHelpers::Terraform.create_environment! }
        .to raise_error('Environment couldn\'t be created.')
    end
  end

  context 'When we destroy our environment from an auto-generated plan' do
    it 'It should perform `terraform destroy` successfully' do
      expect(RakeHelpers::Terraform.destroy_environment!).to be nil
      expect(stubbed_terraform.with_args('destroy')).to be_called
    end

    it "It should error when the environment couldn't be destroyed" do
      stubbed_terraform.with_args('destroy').returns_exitstatus(1)
      expect { RakeHelpers::Terraform.destroy_environment! }
        .to raise_error('Environment couldn\'t be destroyed.')
    end
  end
end
