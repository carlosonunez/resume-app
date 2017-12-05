require 'kramdown'

# ResumeApp module.
module ResumeApp
  # This module contains helpful converters. This might be used
  # in the future to enable different routes, such as '/pdf' or
  # '/text'.
  module Converters
    # Converts a Markdown string into HTML using Kramdown.
    #
    # @param [String] markdown_string The string to convert.
    # @return [String] if markdown_string could be successfully converted.
    #
    #--
    # TODO: Actually convert to HTML!
    #++
    def self.markdown_to_html(markdown_string)
      Kramdown::Document.new(markdown_string).to_html
    end
  end
end
