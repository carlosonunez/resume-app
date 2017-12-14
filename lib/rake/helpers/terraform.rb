require 'open3'

# Rake helpers.
module RakeHelpers
  # Terraform stuff.
  module Terraform
    # Initializes a Terraform directory. This writes a .terraform directory
    # to the working directory, hence the unsafe warning.
    def self.initialize!
      %w[init get].each do |terraform_action|
        TerraformRunner.run_terraform_command terraform_action
      end
    end

    # Determine whether the configuration code provided generates a valid plan.
    def self.plan_valid?
      _, _, was_successful = TerraformRunner.run_terraform_command 'plan'
      was_successful
    end

    # Nested module for doing Terraform actions.
    module TerraformRunner
      # Runs a Terraform command using the `terraform` binary.
      # Returns a tuple containing stdout, stderr and the result of the op.
      # Throws exception if command fails.
      def self.run_terraform_command(action, other_terraform_args = '')
        output, errors, status = Open3.capture3('terraform',
                                                action,
                                                other_terraform_args)
        raise "Terraform failed to #{action}." \
          unless status.exitstatus.zero?
        [output, errors, status.success?]
      end
    end
  end
end
