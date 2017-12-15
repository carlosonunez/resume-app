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
  configuration.after(:all) do
    MockEnv.unmock_all!
  end
end
