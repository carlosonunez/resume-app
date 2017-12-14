require 'open3'

# Rake helpers.
module RakeHelpers
  # Terraform stuff.
  module Terraform
    def initialize!
      %w[init get].each do |terraform_action|
        _, _, status = Open3.capture3("terraform #{terraform_action}")
        raise "Terraform failed to #{terraform_action}." \
          unless status.zero?
      end
    end
  end
end
