# frozen_string_literal: true

module RSpecHelpers
  # This module defines a series of test types supported by our Terraform
  # RSpec "plugin."
  # Each test type can return a 1-3 tuple containing:
  # - The test result
  # - The value expected by the test that should be shown to the user, and
  # - The actual value found within the Terraform plan that should be shown.
  #
  # Additionally, each method *must* take the following two arguments:
  # - expected: The expected value for the test, and
  # - actual: The actual value for the test.
  #
  # TerraformTestMatchers.find_test_and_run_it sends the test definition
  # for the Terraform resource under test as well with the
  # `test_definition` parameter. If you don't need this, add a
  # **other argument to your method parameters.
  #
  # If you don't need the test_definition for your test, set it to `nil`.
  # We recommend creating a new test matcher type for each new test
  # type created here. See `terraform_test_matchers.rb` for more information
  # on how to achieve this.
  module TerraformTestTypes
    def self.num_comparison_valid?(expected:,
                                   actual:,
                                   test_definition:,
                                   expr: nil)
      expressions_map = {
        should_be_less_than: '<',
        should_be_greater_than: '>',
        should_contain_at_least: '>=',
        should_contain_at_most: '<=',
        should_contain_exactly: '==',
        should_not_be: '!=',
        should_at_least_be: '>=',
        should_at_most_be: '<='
      }
      left = actual.to_f
      right = expected.to_f
      puts "Left: #{left}, Right: #{right}"
      raise 'Nothing to compare against!' if right.nil?
      test_verb =
        TerraformTestMatchers.get_test_verb(test_definition)
      expr ||= expressions_map[test_verb]
      raise "No expression found for verb '#{test_verb}'" if expr.nil?
      expected_value_to_print = "#{expr} #{right}"
      # Unfortunately, some of the invocations required to run the tests
      # defined below require the use of `eval`. However, since our input
      # is validated prior to each invocation, this should be safe.
      # rubocop:disable Security/Eval
      expression_to_evaluate = "#{left} #{expr} #{right}"
      result = eval(expression_to_evaluate)
      # rubocop:enable Security/Eval
      [result, expected_value_to_print]
    end

    def self.json_equality_valid?(expected:, actual:, **)
      expected = JSON.parse(expected) if expected.is_a?(String)
      actual = JSON.parse(actual) if actual.is_a?(String)
      is_equal?(left: expected,
                right: actual)
    end

    def self.string_equality_valid?(expected:, actual:, **)
      is_equal?(left: expected.to_s,
                right: actual.to_s)
    end

    def self.arrays_equal?(expected:, actual:, **)
      is_equal?(left: [expected].flatten.sort,
                right: actual.sort)
    end

    def self.array_length_meets_size_requirements?(expected:,
                                                   actual:,
                                                   test_definition:)
      num_comparison_valid?(expected: expected,
                            actual: [actual].flatten.count,
                            test_definition: test_definition)
    end

    def self.is_equal?(left:, right:)
      left == right
    end

    private_class_method :is_equal?
  end
end
