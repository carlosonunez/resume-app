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
    def self.num_comparison_valid?(expected:, actual:, test_def:, expr)
      expressions_map = {
        should_be_less_than: '<',
        should_be_greater_than: '>',
        should_contain_at_least: '<=',
        should_contain_at_most: '>=',
        should_contain_exactly: '==',
        should_not_be: '!='
      }
      left = actual.to_f
      right = expected.to_f
      raise 'Nothing to compare against!' if right.nil?
      expr ||= expressions_map[TerraformTestMatchers.get_test_verb(test_def)]
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
      is_equal?(left: expected,
                right: actual)
    end

    def self.string_equality_valid?(expected:, actual:)
      is_equal?(left: expected.to_s,
                right: actual.to_s)
    end

    def self.arrays_equal?(expected:, actual:)
      is_equal?(left: [expected].flatten.sort,
                right: actual.sort)
    end

    def self.array_length_meets_size_requirements?(expected:,
                                                   actual:,
                                                   test_def:)
      expressions_map = {
        should_contain_at_least: '<=',
        should_contain_at_most: '>=',
        should_contain_exactly: '=='
      }
      expression = TerraformTestMatchers.get_test_verb(test_def)
      num_comparison_valid(expected: expected,
                           actual: actual,
                           test_def: test_def,
                           expr: expression)
    end

    def self.is_equal?(left:, right:)
      left == right
    end

    private_class_method :is_equal?
  end
end
