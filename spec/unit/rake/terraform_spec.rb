require 'spec_helper'

describe 'Given a helper Rake library for executing Terraform tasks' do
  before(:all) do
    @test_terraform_config = <<-TERRAFORM
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/8"
}
    TERRAFORM

    @expected_partial_terraform_output = <<-TERRAFORM
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


Plan: 1 to add, 0 to change, 0 to destroy
    TERRAFORM

    @expected_exit_code = 0

    let(:stubbed_shell) { create_stubbed_env }
  end

  context 'When we initialize Terraform' do
    %w[init get].each do |terraform_action|
      it 'Should perform a Terraform init and Terraform get' do
        let!(:stubbed_terraform) { stubbed_shell.stub_command('terraform') }
        let(:terraform_action) { stubbed_terraform.with_args(terraform_action) }
        RakeHelpers::Terraform.initialize!
        expect(terraform_action).to be_called
      end

      it 'Should return a friendly error message when init and get fail' do
        stubbed_shell.stub_command("terraform #{terraform_action}")
          .returns_exitstatus(1)
        expect { RakeHelpers::Terraform.initialize! }
          .to raise_error("Terraform failed to #{terraform_action}.")
      end
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
