#!/usr/bin/env ruby

# Helpers used by Rake to do stuff, like deploy to ECS.
module RakeHelpers
  # Helpers for AWS.
  module AWS
    # Helpers for AWS ECS, Amazon's custom container orchestration platform.
    module ECS
      # Generates a AWS ECS task definition from environment variables.
      def self.generate_task_json!
        %w[
          S3_BUCKET_NAME
          AWS_ACCESS_KEY_ID
          AWS_SECRET_ACCESS_KEY
        ].each do |required_env_var|
          raise IOError, "#{required_env_var} is missing. Please provide it." \
            unless !(ENV[required_env_var].empty? ||
                     ENV[required_env_var].nil?)
        end
        raise IOError, 'ecs_task_template.json is missing. Please provide it.' \
          unless File.exist?('ecs_task_template.json')
      end
    end
  end
end
