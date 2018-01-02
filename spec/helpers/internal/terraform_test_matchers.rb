# frozen_string_literal: true

module RSpecHelpers
  module TerraformTestMatchers
    COMPARE_JSON = :json
    COMPARE_STRINGS = :string
    COMPARE_TWO_NUMBERS = :numerical_comparison
    COMPARE_ARRAYS = :array
    COMPARE_ARRAY_LENGTHS = :array_count
    SUPPORTED_MATCHER_TYPES = [COMPARE_JSON,
                               COMPARE_STRINGS,
                               COMPARE_TWO_NUMBERS,
                               COMPARE_ARRAYS,
                               COMPARE_ARRAY_LENGTHS]
    SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS = {
      should_be: COMPARE_JSON
      should_at_least_be: COMPARE_TWO_NUMBERS
      should_at_most_be: COMPARE_TWO_NUMBERS
      should_be_less_than: COMPARE_TWO_NUMBERS
      should_be_greater_than: COMPARE_TWO_NUMBERS
      should_contain_at_least: COMPARE_ARRAY_LENGTHS
      should_contain_at_most: COMPARE_ARRAY_LENGTHS
      should_contain_exactly: COMPARE_ARRAY_LENGTHS
    }
    # Test definition matchers allow you to specify different ways of
    # testing expected values.
    # In most cases, we recommend using one of the test verbs above.
    def self.get_test_definition_matcher(test_definition)
      test_verb = get_test_verb(test_definition).to_sym
      default_matcher_type =
        SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS[test_verb] || COMPARE_STRINGS
      desired_matcher_type =
        test_definition[:matcher_type] || default_matcher_type
      return default_matcher_type unless
        SUPPORTED_MATCHER_TYPES.include?(desired_matcher_type)
      desired_matcher_type
    end

    def self.get_expected_value(test_definition)
      test_verb = get_test_verb(test_definition)
      test_definition[test_verb]
    end

    def self.get_test_verb(test_definition)
      supported_verbs = SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS.keys
      found_verb = test_definition.slice(supported_verbs).keys.first
      unless found_verb
        raise "Couldn't find any of these in your test def: #{supported_verbs}"
      end
    end
  end
end
