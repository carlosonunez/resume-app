require 'aws-sdk'

# ResumeApp
module ResumeApp
  # Various helper functions for ResumeApp.
  module Helpers
    # Helper functions for AWS.
    module AWS
      # Retrieves and reads a resume from a S3 bucket.
      # @Params
      #
      # [string] bucket_name The name of the bucket to pull from.
      # [string] resume_name The name of the resume to retrieve.
      #          Defaults to 'latest'
      #
      # @returns
      # [string] of resume text found or [Exception] otherwise.
      def self.retrieve_resume
        %w[
          AWS_ACCESS_KEY_ID
          AWS_SECRET_ACCESS_KEY
          AWS_REGION
        ].each do |required_var|
          next if ENV[required_var]
          raise "#{required_var} needs to be set before running this. " \
                'Set it by running `aws configure` or putting it in ' \
                'your `.env`'
        end
        s3_bucket_name = ENV['S3_BUCKET_NAME']
        resume_name = ENV['RESUME_NAME'] || 'latest'
        begin
          s3_client = Aws::S3::Client.new
          s3_client.get_object(
            bucket: s3_bucket_name,
            key: resume_name
          ).read
        rescue Aws::S3::Errors::NoSuchKey
          raise "We couldn't find #{resume_name} in bucket #{s3_bucket_name}"
        rescue Aws::S3::Errors::ServiceError => e
          raise "An unknown error occurred with AWS: #{e.message}"
        end
      end
    end
  end
end
