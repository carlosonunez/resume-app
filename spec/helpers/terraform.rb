# frozen_string_literal: true

module RSpecHelpers
  module Terraform
    def self.initialize
      unless File.exist?('terraform.tfplan.json')
        raise 'Terraform plan JSON not found.'
      end
      JSON.parse(File.read('terraform.tfplan.json'))
    end

    # I'm not sure why this is triggering this cop. I'm guessing that
    # this has something to do with the RSpec verbs.
    # Therefore, I'm disabling it for now.
    # NOTE: I'm fully aware that this is better suited as an RSpec plugin.
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    def self.run_tests(resource_name:,
                       requirements_hash:)
      RSpec.describe 'Given a repository of Terraform configurations',
                     terraform: true do
        context "When I define \"#{resource_name}\"" do
          it 'It should not be empty' do
            expect(@terraform_plan[resource_name]).not_to be nil
          end
          requirements_hash.each_key do |requirement|
            # Since RSpec doesn't easily support calling functions within
            # modules, instead of building an array of requirements and
            # recursively running tests on each one, we'll need to have
            # users address the Terraform resource argument they want
            # to test with dot-notation.
            #
            # Example: Given the following resource:
            #
            # "test_resource"."my_resource" {
            #   foo = "bar"
            #   baz {
            #     quux = "cool"
            #   }
            # }
            #
            # If I wanted to ensure that 'quux' is set to "cool", I'd need to
            # do this:
            #
            # requirements = {
            #  'baz.quux' = {
            #    ...
            #    should_be: "cool"
            #  }
            # }
            #
            # This small function is what makes this work.
            if requirement.match?('\.')
              root_requirement, remaining_requirements =
                requirement.split('.')
              remaining_requirements =
                remaining_requirements.map { |x| "[#{x}]" }.join('')
              # While eval is usually a security risk (arb. code execution),
              # I don't know of another way of obtaining a hash key by string.
              # Therefore, we'll disable this check here.
              # rubocop:disable Security/Eval
              requirement_under_test = eval('requirements_hash' \
                                            "[#{root_requirement}]" \
                                            "#{remaining_requirements}")
              # rubocop:enable Security/Eval
            else
              requirement_under_test = requirements_hash[requirement]
            end
            test_name = requirement_under_test[:test_name]
            if test_name.downcase.match?(/^it should/)
              example_name = test_name
            else
              warn '[WARN] ' \
                "Test name is not in 'It-should' format: #{test_name}".cyan
              example_name = 'It should have a correct ' \
                "#{resource_name}.#{requirement}"
            end
            it example_name do
              expected_value = requirement_under_test[:should_be]
              actual_value = @terraform_plan[resource_name][requirement.to_s]
              matcher = if requirement_under_test.key?(:matcher_type)
                          requirement_under_test[:matcher_type]
                        else
                          :string
                        end
              case matcher
              when :json
                expected_json = expected_value
                actual_json = JSON.parse(actual_value)
                expect(expected_json).to eq actual_json
              else
                expect(expected_value.to_s).to eq actual_value.to_s
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
