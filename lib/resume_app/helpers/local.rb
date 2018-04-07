# frozen_string_literal: true

# ResumeApp
module ResumeApp
  # Various helper functions for ResumeApp.
  module Helpers
    # Helper functions for AWS.
    module Local
      # Retrieves and reads a resume from a local filesystem.
      # It uses 'RESUME.md' as the default, but this can be changed
      # by setting LOCAL_RESUME_NAME.
      # 
      # @returns
      # [string] of resume text found or [Exception] otherwise.
      def self.retrieve_resume
        resume_name = ENV['LOCAL_RESUME_NAME'] || 'RESUME.md'
        File.read(resume_name)
      end
    end
  end
end
