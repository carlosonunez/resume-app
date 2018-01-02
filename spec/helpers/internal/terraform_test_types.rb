# frozen_string_literal: true

module RSpecHelpers
  module TerraformTestTypes
    # Unfortunately, some of the invocations required to run the tests
    # defined below require the use of `eval`. However, since our input
    # is validated prior to each invocation, this should be safe.
    # rubocop:disable Security/Eval
    def self.num_comparison_valid?(actual:, test_def:)
      left = actual.to_f
      right = test_def[:number_to_compare_against].to_f
      expr = test_def[:should_be]
      raise 'Nothing to compare against!' if right.nil?
      valid_expressions = %w[< <= == != >= >]
      unless valid_expressions.include?(expr)
        raise "Expression #{expr} must be one of these: #{valid_expressions}"
      end
      eval("#{left} #{expr} #{right}")
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
    # rubocop:ensable Security/Eval
  end
end
