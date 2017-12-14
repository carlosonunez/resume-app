require 'bundler/setup'
Bundler.setup

require 'resume_app'
require 'rack/test'
require 'aws-sdk'
require 'colorize'
require 'dotenv'
require 'rspec/shell/expectations'

Dotenv.load('.env.test')
RSpec.configure do |configuration|
  configuration.include Rspec::Shell::Expectations
end
