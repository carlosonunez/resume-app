module RSpecHelpers
  module Terraform
    def self.initialize
      command_string = '/usr/bin/terraform plan ' \
        '-out /tmp/temp.tfplan'
      _, errors, result = Open3.capture3(command_string)
      unless result.success?
        raise "Failed to create Terraform plan. Here's why: #{errors}" \
      end
      serialized_plan_json, errors, result =
        Open3.capture3('tfjson /tmp/temp.tfplan')
      unless result.success?
        raise "Failed to capture JSON of Terraform plan. Here's why: #{errors}"
      end
      JSON.parse(serialized_plan_json)
    end
  end
end
