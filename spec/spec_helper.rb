require 'bundler/setup'
Bundler.setup

require 'resume_app'
require 'rack/test'
require 'aws-sdk'
require 'colorize'
require 'dotenv'
Dotenv.load('.env.test')
