require 'rspec/core/rake_task'
require 'dotenv/tasks'
require 'colorize'

namespace :test do
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.rspec_opts = [ '--color', '-f progress', '-r ./spec/spec_helper.rb' ]
    task.pattern = 'spec/**/*_spec.rb'
  end
end

namespace :deploy do
  # TODO: Deploy to Fargate here
end
