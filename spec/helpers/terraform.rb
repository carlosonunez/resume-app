# frozen_string_literal: true

module RSpecHelpers
  module Terraform
    def self.initialize
      unless File.exist?('terraform.tfplan.json')
        raise 'Terraform plan JSON not found.'
      end
      JSON.parse(File.read('terraform.tfplan.json'))
    end

    def self.run_tests(resource_name:,
                       requirements_hash:)
      requirements_hash.each_key do |requirement|
        test_name = requirements_hash[requirement][:test_name]
        expected_value = requirements_hash[requirement][:should_be].to_s
        it "It #{test_name}" do
          actual_value =
            @terraform_plan[resource_name][requirement.to_s].to_s
          expect(actual_value).to eq expected_value
        end
      end
    end
  end
end
