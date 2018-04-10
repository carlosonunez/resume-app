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

      # Generates a temporary PDF file in the 'public' directory
      # @returns
      # [string] containing the path to the PDF.
      def self.generate_temp_public_pdf_file
        require 'securerandom'
        create_public_directory_if_not_present!
        file_nonce = SecureRandom.hex[0..7]
        file_path = "./public/resume_#{file_nonce}.pdf"
        File.write(file_path, '')
        file_path
      end

      # Deletes a file.
      # @returns
      # [boolean] Result of the deletion.
      def self.delete_file(file_path)
        File.delete(file_path)
      end

      # Checks to see if 'public' exists and creates it if it doesn't.
      # @returns
      # [boolean] Result of the check or creation operation.
      def self.create_public_directory_if_not_present!
        FileUtils.mkdir('./public') unless Dir.exist?('./public')
      end

      private_class_method :create_public_directory_if_not_present!
    end
  end
end
