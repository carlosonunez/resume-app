require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'
require 'dotenv'

namespace :static_analysis do
  desc 'Run lint and style guide confirmation tests.'
  RuboCop::RakeTask.new(:style) do |task|
    task.options = ['-a']
  end
end

ENV['COVERAGE'] = 'true'
['unit','integration'].each do |test_type|
  namespace test_type.to_sym do
    Dotenv.load(".env.#{test_type}") unless !File.exist?(".env.#{test_type}")
    desc "Runs #{test_type} tests, along with setup and teardown procedures."
    RSpec::Core::RakeTask.new(:test) do |task|
      task.pattern = "spec/#{test_type}/**/*_spec.rb"
      task.fail_on_error = true
      task.rspec_opts = '--format documentation'
    end
  end
end

task test: %i[static_analysis:style unit:test integration:test]

task :deploy do
  # TODO: Deploy to Fargate here
end

task default: :test
