# frozen_string_literal: true

require 'kramdown'
require 'pdfkit'
require 'securerandom'

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
    def self.markdown_to_html(markdown_string)
      Kramdown::Document.new(markdown_string).to_html
    end

    # Converts a Markdown string into PDF using Kramdown.
    #
    # @param [String] markdown_string The string to convert.
    # @return [PDF] A PDF document from Prawn if successful.
    def self.markdown_to_pdf(markdown)
      markdown_html = markdown_to_html(markdown)
      puts "HTML received: #{markdown_html}"
      PDFKit.configure do |config|
        config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
        config.default_options = {
          page_size: 'Letter',
          quiet: true
        }
      end
      kit = PDFKit.new(markdown_html)
      kit.to_pdf
    end
  end
end
