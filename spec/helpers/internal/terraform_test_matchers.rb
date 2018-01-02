# frozen_string_literal: true

module RSpecHelpers
  module TerraformTestMatchers
    SUPPORTED_MATCHER_TYPES = %i[json
    string
    numerical_comparison
    array
    array_count].freeze
    SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS = {
      should_be: 'string'
      should_at_least_be: 'numerical_comparison'
      should_at_most_be: 'numerical_comparison'
      should_be_less_than: 'numerical_comparison'
      should_be_greater_than: 'numerical_comparison'
      should_contain_at_least: 'array_count'
      should_contain_at_most: 'array_count'
      should_contain_exactly: 'array_count'
    }
    # Test definition matchers allow you to specify different ways of
    # testing expected values.
    # In most cases, we recommend using one of the test verbs above.
    def self.get_test_definition_matcher(test_definition)
      test_verb = get_test_verb(test_definition).to_sym
      default_matcher_type =
        SUPPORTED_TEST_VERBS_AND_THEIR_MATCHERS[test_verb] || :string
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
