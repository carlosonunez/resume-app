require 'open3'

# Rake helpers.
module RakeHelpers
  # Terraform stuff.
  module Terraform
    # Initializes a Terraform directory.
    # The `get` action writes a .terraform directory to the working directory,
    # hence the unsafe warning.
    def self.initialize!
      %w[init get].each do |terraform_action|
        _, _, was_successful =
          TerraformRunner.run_terraform_command(action: terraform_action)
        raise "Terraform failed to #{terraform_action}." unless was_successful
      end
      nil
    end

    # Determine whether the configuration code provided generates a valid plan.
    def self.plan_valid?
      _, _, was_successful =
        TerraformRunner.run_terraform_command(action: 'plan')
      was_successful
    end

    # Create the environment with `terraform plan`
    def self.create_environment!
      _, _, was_successful =
        TerraformRunner.run_terraform_command(action: 'apply')
      raise 'Environment could not be created.' unless was_successful
      nil
    end

    # Nested module for doing Terraform actions.
    module TerraformRunner
      # Runs a Terraform command using the `terraform` binary.
      # Returns a tuple containing stdout, stderr and the result of the op.
      # Throws exception if command fails.
      def self.run_terraform_command(action:, other_terraform_args: '')
        output, errors, status = Open3.capture3('terraform',
                                                action,
                                                other_terraform_args)
        [output, errors, status.success?]
      end
    end
  end
end
