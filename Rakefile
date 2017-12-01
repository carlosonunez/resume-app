require 'rspec/core/rake_task'
require 'dotenv/tasks'
require 'colorize'

task :test do
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.rspec_opts = [ '--color', '-f progress' ]
  end
end

task :deploy do
  # TODO: Deploy to Fargate here
end

task :default => :test
