# frozen_string_literal: true
module RSpecHelpers
  module TerraformTestMatchers
    # Test definition matchers allow you to specify different ways of
    # testing expected values.
    def self.get_test_definition_matcher(test_definition)
      supported_matcher_types = %i[json string numerical_comparison]
      default_matcher_type = :string
      desired_matcher_type =
        test_definition[:matcher_type] || default_matcher_type
      return default_matcher_type unless
        supported_matcher_types.include?(desired_matcher_type)
      desired_matcher_type
    end
  end
end
