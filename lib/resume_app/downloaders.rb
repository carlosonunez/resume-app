# frozen_string_literal: true

require 'aws-sdk-s3'
require 'resume_app/helpers/aws'

# ResumeApp.
module ResumeApp
  # This module contains methods for downloading things, such as resumes!
  module Downloaders
    # Downloads a resume from an S3 bucket provided by [.env].
    # The resume is expected to be named 'latest', but this can be changed from
    # within your [.env]. See the [README] for more information.
    #
    # @param [String] s3_bucket The bucket to locate the Markdown resume from.
    #
    # @returns [String] if found, or [nil] if not found.
    def self.retrieve_latest_resume_as_markdown
      provider = ENV['CLOUD_PROVIDER'] || 'AWS'
      case provider.downcase
      when 'aws'
        resume_markdown_found = Helpers::AWS.retrieve_resume
      when 'local'
        resume_markdown_found = Helpers::Local.retrieve_resume
      else
        raise RuntimeError("Cloud provider #{provider} isn't supported yet.")
      end

      unless resume_markdown_found
        raise RuntimeError("We couldn't find any resumes in your account. " \
                           "Check that you've configured your `.env` correctly.")
      end
      resume_markdown_found
    end
  end
end
