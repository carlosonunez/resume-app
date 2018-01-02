# frozen_string_literal: true

module RSpecHelpers
  module TerraformTestMatchers
    SUPPORTED_MATCHER_TYPES = %i[json string numerical_comparison array].freeze
    # Test definition matchers allow you to specify different ways of
    # testing expected values.
    def self.get_test_definition_matcher(test_definition)
      default_matcher_type = :string
      desired_matcher_type =
        test_definition[:matcher_type] || default_matcher_type
      return default_matcher_type unless
        SUPPORTED_MATCHER_TYPES.include?(desired_matcher_type)
      desired_matcher_type
    end
  end
end
