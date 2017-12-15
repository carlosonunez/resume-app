require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'
require 'dotenv'
require_relative 'lib/rake/helpers/terraform.rb'

namespace :static_analysis do
  desc 'Run lint and style guide confirmation tests.'
  RuboCop::RakeTask.new(:style) do |task|
    task.options = ['-a']
  end

  task all: :style
end

ENV['COVERAGE'] = 'true'
%w[unit integration].each do |test_type|
  namespace test_type.to_sym do
    desc "Runs #{test_type} tests, along with setup and teardown procedures."

    RSpec::Core::RakeTask.new(:test) do |task|
      Rake::Task['static_analysis:all'].invoke
      task.pattern = "spec/#{test_type}/**/*_spec.rb"
      task.fail_on_error = true
      task.rspec_opts = '--format documentation --fail-fast'
    end
  end
end

task test: %i[unit:test integration:test]

task default: :test
