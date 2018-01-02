# frozen_string_literal: true

module RSpecHelpers
  # This module defines a series of test types supported by our Terraform
  # RSpec "plugin."
  # Each test type can return a 1-3 tuple containing:
  # - The test result
  # - The value expected by the test that should be shown to the user, and
  # - The actual value found within the Terraform plan that should be shown.
  #
  # We recommend creating a new test matcher type for each new test
  # type created here. See `terraform_test_matchers.rb` for more information
  # on how to achieve this.
  module TerraformTestTypes
    def self.num_comparison_valid?(actual:, test_def:)
      left = actual.to_f
      right = test_def[:number_to_compare_against].to_f
      expr = test_def[:should_be]
      raise 'Nothing to compare against!' if right.nil?
      valid_expressions = %w[< <= == != >= >]
      unless valid_expressions.include?(expr)
        raise "Expression not valid: #{expr}. " \
          "Valid expressions are: #{valid_expressions}"
      end
      expected_value_to_print = "#{expr} #{right}"
      # Unfortunately, some of the invocations required to run the tests
      # defined below require the use of `eval`. However, since our input
      # is validated prior to each invocation, this should be safe.
      # rubocop:disable Security/Eval
      result = eval("#{left} #{expr} #{right}")
      # rubocop:enable Security/Eval
      [result, expected_value_to_print]
    end

    def self.json_equality_valid?(expected:, actual:)
      expected = JSON.parse(expected) if expected.is_a?(String)
      actual = JSON.parse(actual) if actual.is_a?(String)
      expected == actual
    end

    def self.string_equality_valid?(expected:, actual:)
      expected.to_s == actual.to_s
    end

    def self.arrays_equal?(expected:, actual:)
      [expected].flatten.sort == actual.sort
    end

    def self.array_length_meets_size_requirements?(expected:, actual:)
      expected == actual.count
    end
  end
end
