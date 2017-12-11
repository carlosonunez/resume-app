#!/usr/bin/env ruby
require 'json'
require_relative '../../../../lib/rake/helpers/json.rb'

# Helpers used by Rake to do stuff, like deploy to ECS.
module RakeHelpers
  # Helpers for AWS.
  module AWS
    # Helpers for AWS ECS, Amazon's custom container orchestration platform.
    module ECS
      # Stores template values used by our task definition generator.
      class Template
        def values
          {
            S3_BUCKET_NAME: ENV['S3_BUCKET_NAME'],
            RESUME_NAME: if ENV['RESUME_NAME'].to_s.empty?
                           'latest'
                         else
                           ENV['RESUME_NAME']
                         end
          }
        end
      end

      # Generates a AWS ECS task definition from environment variables.
      def self.generate_task_json!
        %w[
          S3_BUCKET_NAME
          AWS_ACCESS_KEY_ID
          AWS_SECRET_ACCESS_KEY
          VERSION
        ].each do |required_env_var|
          raise IOError, "#{required_env_var} is missing. Please provide it." \
            if ENV[required_env_var].empty? ||
               ENV[required_env_var].nil?
        end
        raise IOError, 'ecs_task_template.json is missing. Please provide it.' \
          unless File.exist?('ecs_task_template.json')
        templated_ecs_task_definition =
          JSON.parse(File.read('ecs_task_template.json'))
        JSONHelpers.create_hash_from_template(templated_ecs_task_definition,
                                              Template.values)
        File.write('ecs_task_definition.json', templated_ecs_task_definition)
      end
    end
  end
end
