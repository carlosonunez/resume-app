module ResumeApp
  module Downloaders
    # Downloads a resume from an S3 bucket provided by [.env].
    # The resume is expected to be named 'latest', but this can be changed from
    # within your [.env]. See the [README] for more information.
    #
    # @param [String] s3_bucket The bucket to locate the Markdown resume from.
    #
    # @returns [String] if found, or [nil] if not found.
    def self.retrieve_latest_resume_from_s3
      puts "In progress"
    end
  end
end
