# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'resume_app'
require 'rack/test'
require 'aws-sdk-s3'
require 'colorize'
require 'dotenv'
Dotenv.load('.env.example')

require 'rspec/shell/expectations'
require './spec/helpers/terraform/terraform'
require './spec/helpers/terraform/terraform_plan'
require './spec/helpers/terraform/terraform_test'
require './spec/helpers/environment'
require './spec/helpers/json'

module Mixins
  include Rack::Test::Methods
  def app
    ResumeApp::Web::App
  end
end

RSpec.configure do |configuration|
  configuration.include Mixins
  configuration.before(:all, terraform: true) do
    @terraform_plan = RSpecHelpers::Terraform.initialize
  end
  configuration.before(:all) do
    @test_local_markdown_content = <<-MARKDOWN
This document is stored locally.
===============================

No network access required!
MARKDOWN
    @test_local_html_content = <<-MARKDOWN
<h1 id="this-document-is-stored-locally">This document is stored locally.</h1>\n
<p>No network access required!</p>
MARKDOWN
    @test_markdown_content = <<-MARKDOWN
This is a document.
===================

A document can have many sections!
----------------------------------

It has words. Some of them are **bold,** and some of them are *emphasized.*
MARKDOWN

    @test_html_content = <<-HTML
<h1 id="this-is-a-document">This is a document.</h1>\n
<h2 id="a-document-can-have-many-sections">A document can have many sections!</h2>\n
<p>It has words. Some of them are <strong>bold,</strong> and some of them are <em>emphasized.</em></p>
HTML
  end
end
