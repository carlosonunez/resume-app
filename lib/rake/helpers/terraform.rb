# frozen_string_literal: true

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
        TerraformRunner.simple_run!(action: terraform_action)
      end
      nil
    end

    # Determine whether the configuration code provided generates a valid plan.
    def self.plan_valid?
      _, _, was_successful =
        TerraformRunner.run!(action: 'plan')
      was_successful
    end

    # Create the environment with `terraform plan`
    def self.create_environment!
      error_message = 'Environment couldn\'t be created.'
      TerraformRunner.simple_run!(action: 'apply',
                                  error_message: error_message)
    end

    # Destroy the environment with `terraform destroy`
    def self.destroy_environment!
      error_message = 'Environment couldn\'t be destroyed.'
      TerraformRunner.simple_run!(action: 'destroy',
                                  error_message: error_message)
    end

    # Nested module for doing Terraform actions.
    module TerraformRunner
      # Runs a Terraform command using the `terraform` binary.
      # Returns a tuple containing stdout, stderr and the result of the op.
      # Throws exception if command fails.
      def self.run!(action:,
                    other_terraform_args: '')
        if other_terraform_args.empty?
          output, errors, status = Open3.capture3('terraform',
                                                  action)
        else
          output, errors, status = Open3.capture3('terraform',
                                                  action,
                                                  other_terraform_args)
        end
        [output, errors, status.success?]
      end

      # Simply execute a Terraform action and return nothing.
      # Could modify system or environment state, hence unsafe warning.
      def self.simple_run!(action:, other_args: '', error_message: '')
        _, errors, was_successful =
          TerraformRunner.run!(action: action,
                               other_terraform_args: other_args)
        error_message = "Terraform failed to #{action}." if error_message.empty?
        error_message = "#{error_message}\nHere's what happened:\n#{errors}"
        raise error_message unless was_successful
        nil
      end
    end
  end
end
