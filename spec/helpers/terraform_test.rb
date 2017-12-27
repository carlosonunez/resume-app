# frozen_string_literal: true

module RSpecHelpers
  module TerraformTest
    # Validates whether a given argument within a Terraform resource
    # was found inside of the Terraform plan.
    # There are three types within HCL for Terraform:
    #   - String
    #   - Map
    #   - Array
    # To test [string] or [array] arguments, simply use the name of the string.
    # e.g. To test "aws_vpc.cidr_block", use "cidr_block" for your test def.
    #
    # To test [map] arguments, refer to it with dot-notation.
    # e.g. Given the following resource structure:
    # aws_lb {
    #   load_balancer {
    #     name
    #   }
    # }
    # To test "name", use "load_balancer.name". TerraformTest will automatically
    # search all 'load_balancer' maps within this resource for those that match
    # the name given in the [:should_be] argument.
    def self.resource_path_is_within_plan?(plan:,
                                           resource_name:,
                                           resource_arg:)
      !get_actual_value(plan, resource_name, resource_arg).nil?
    end

    # Fetch the actual value for a resource name and argument within a plan.
    # I don't know how to reduce the Abc Size of this right now.
    # rubocop:disable Metrics/AbcSize
    def self.get_actual_value(plan,
                              resource_name,
                              resource_arg)
      enumerable_argument, parameter_to_find, remainder =
        resource_arg.to_s.split('.')
      if parameter_to_find.nil?
        plan[resource_name][resource_arg.to_s]
      elsif !remainder.nil?
        warn "#{resource_name}.#{resource_arg} is too deeply nested." \
          'This is currently not supported by TerraformTest.'
        return nil
      else
        return nil unless plan[resource_name].key?(enumerable_argument)
        found_arguments =
          plan[resource_name][enumerable_argument].select do |map|
            map.key?(parameter_to_find)
          end
        found_values = []
        found_arguments.each do |parameter_map|
          found_values.push(parameter_map[parameter_to_find])
        end
        found_values.join(',')
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Generate the example name for test definitions.
    def self.create_example_name(test_definition,
                                 resource_name,
                                 resource_argument)
      test_name = test_definition[:test_name]
      if test_name.downcase.match?(/^it should/)
        test_name
      else
        warn '[WARN] ' \
          "Test name is not in 'It-should' format: #{test_name}".cyan
        "It should have a correct #{resource_name}.#{resource_argument}"
      end
    end

    # Run the Terraform test.
    def self.run_test(test_definition:, plan:, resource_name:, resource_arg:)
      expected_value = test_definition[:should_be]
      actual_value = get_actual_value(plan, resource_name, resource_arg)
      case get_test_definition_matcher(test_definition)
      when :json
        expected_json = expected_value
        actual_json = JSON.parse(actual_value)
        return 'Pass' if expected_json == actual_json
      else
        return 'Pass' if expected_value.to_s == actual_value.to_s
      end
      <<-TEST_FAILURE_SUMMARY
      Fail.
      Resource under test: #{resource_name}
      Argument under test: #{resource_arg}
      Expected value: #{expected_value}
      Actual value: #{actual_value}
      TEST_FAILURE_SUMMARY
    end

    # Test definition matchers allow you to specify different ways of
    # testing expected values.
    def self.get_test_definition_matcher(test_definition)
      supported_matcher_types = %i[json string]
      default_matcher_type = :string
      desired_matcher_type =
        test_definition[:matcher_type] || default_matcher_type
      return default_matcher_type unless
        supported_matcher_types.include?(desired_matcher_type)
      desired_matcher_type
    end

    private_class_method :get_test_definition_matcher
  end
end
