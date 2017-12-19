# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'resume_app'
require 'rack/test'
require 'aws-sdk'
require 'colorize'
require 'dotenv'
Dotenv.load('.env.example')

require 'rspec/shell/expectations'
require './spec/helpers/terraform'
require './spec/helpers/environment'
require './spec/helpers/json'

RSpec.configure do |configuration|
  configuration.before(:each, terraform: true) do |_example|
    @terraform_plan = RSpecHelpers::Terraform.initialize
  end
end
