# frozen_string_literal: true

require './spec/helpers/internal/terraform_test_types'

module RSpecHelpers
  module TerraformTestMatchers
    COMPARE_JSON = :json
    COMPARE_STRINGS = :string
    COMPARE_TWO_NUMBERS = :numerical_comparison
    COMPARE_ARRAYS = :array
    COMPARE_ARRAY_LENGTHS = :array_count
    SUPPORTED_MATCHER_TYPES_AND_THEIR_METHODS = {
      COMPARE_JSON => :json_equality_valid?,
      COMPARE_TWO_NUMBERS => :num_comparison_valid?,
      COMPARE_ARRAYS => :arrays_equal?,
      COMPARE_ARRAY_LENGTHS => :array_length_meets_size_requirements?,
      COMPARE_STRINGS => :string_equality_valid?
    }.freeze
    SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS = {
      should_be: COMPARE_STRINGS,
      should_at_least_be: COMPARE_TWO_NUMBERS,
      should_at_most_be: COMPARE_TWO_NUMBERS,
      should_be_less_than: COMPARE_TWO_NUMBERS,
      should_be_greater_than: COMPARE_TWO_NUMBERS,
      should_contain_at_least: COMPARE_ARRAY_LENGTHS,
      should_contain_at_most: COMPARE_ARRAY_LENGTHS,
      should_contain_exactly: COMPARE_ARRAY_LENGTHS,
      json_should_be: COMPARE_JSON
    }.freeze

    def self.get_test_verb(test_definition)
      found_verbs =
        SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS.keys.find_all do |verb|
          test_definition.key?(verb)
        end
      raise "Couldn't find any of these in your test def: #{supported_verbs}" \
        unless found_verbs
      raise "Please provide only one of #{found_verbs}" \
        unless found_verbs.count == 1
      found_verbs.first
    end

    def self.find_test_and_run_it(actual:,
                                  test_def:)
      matcher_type_requested = get_test_definition_matcher(test_def, actual)
      method_to_execute =
        SUPPORTED_MATCHER_TYPES_AND_THEIR_METHODS[matcher_type_requested]
      arguments_hash_to_send = {
        expected: get_expected_value(test_def),
        actual: actual,
        test_definition: test_def
      }
      result, expected_to_print, actual_to_print =
        TerraformTestTypes.send(method_to_execute, arguments_hash_to_send)
      expected_to_print ||= get_expected_value(test_def)
      actual_to_print ||= actual
      [result, expected_to_print, actual_to_print]
    end

    # Test definition matchers allow you to specify different ways of
    # testing expected values.
    # In most cases, we recommend using one of the test verbs above.
    def self.get_test_definition_matcher(test_definition, actual_value)
      test_verb = get_test_verb(test_definition).to_sym
      default_matcher_type =
        SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS[test_verb]
      if default_matcher_type == COMPARE_STRINGS &&
         actual_value.is_a?(Array)
        default_matcher_type = COMPARE_ARRAYS
      end
      desired_matcher_type =
        test_definition[:matcher_type] || default_matcher_type
      return default_matcher_type unless
        SUPPORTED_MATCHER_TYPES_AND_THEIR_METHODS.keys.include?(
          desired_matcher_type
        )
      desired_matcher_type
    end

    def self.get_expected_value(test_definition)
      test_verb = get_test_verb(test_definition)
      test_definition[test_verb]
    end

    private_class_method :get_test_definition_matcher,
                         :get_expected_value
  end
end
