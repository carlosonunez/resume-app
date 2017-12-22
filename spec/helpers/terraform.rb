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
          requirements_hash.each_key do |tf_resource_arg|
            tf_resource_arg_test_definition = requirements_hash[tf_resource_arg]
            test_name = tf_resource_arg_test_definition[:test_name]
            if test_name.downcase.match?(/^it should/)
              example_name = test_name
            else
              warn '[WARN] ' \
                "Test name is not in 'It-should' format: #{test_name}".cyan
              example_name = 'It should have a correct ' \
                "#{resource_name}.#{tf_resource_arg}"
            end
            # Since RSpec doesn't easily support calling functions within
            # modules, instead of building an array of tf_resource_args and
            # recursively running tests on each one, we'll need to have
            # users address the Terraform resource_name argument they want
            # to test with dot-notation.
            #
            # Example: Given the following resource_name:
            #
            # "test_resource_arg"."my_resource_arg" {
            #   foo = "bar"
            #   baz {
            #     quux = "cool"
            #   }
            # }
            #
            # If I wanted to ensure that 'quux' is set to "cool", I'd need to
            # do this:
            #
            # tf_resource_args = {
            #  'baz.quux' = {
            #    ...
            #    should_be: "cool"
            #  }
            # }
            #
            # This small function is what makes this work.
            if tf_resource_arg.match?('\.')
              root_tf_resource_arg, *remaining_tf_resource_args =
                tf_resource_arg.to_s.split('.')
              tf_sub_resource_args =
                remaining_tf_resource_args.map { |x| "['#{x}']" }.join('')
              actual_value_name = resource_name + \
                                  "['#{root_tf_resource_arg}']" + \
                                  tf_sub_resource_args
              actual_value_ref =
                '@terraform_plan[resource_name]' \
                "['#{root_tf_resource_arg}']" + \
                tf_sub_resource_args
              # While eval is usually a security risk (arb. code execution),
              # I don't know of another way of obtaining a hash key by string.
              # Therefore, we'll disable this check here.
            else
              actual_value_name = "#{resource_name}['#{tf_resource_arg}']"
              actual_value_ref =
                '@terraform_plan[resource_name][tf_resource_arg.to_s]'
            end
            # rubocop:disable Security/Eval
            it "It should have a non-empty #{actual_value_name}" do
              expect { eval(actual_value_ref) }
                .not_to raise_error(NoMethodError),
                  "Expected #{actual_value_name} to be present in your " \
                  "Terraform plan, but it was not."
            end
            it example_name do
              expected_value = tf_resource_arg_test_definition[:should_be]
              actual_value = eval(actual_value_ref)
              # rubocop:enable Security/Eval
              matcher = if tf_resource_arg_test_definition.key?(:matcher_type)
                          tf_resource_arg_test_definition[:matcher_type]
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
