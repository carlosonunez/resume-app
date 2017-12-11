require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'

RuboCop::RakeTask.new(:style) do |task|
  task.options = ['-a']
end

ENV['COVERAGE'] = 'true'
['unit','integration'].each do |test_type|
  RSpec::Core::RakeTask.new("#{test_type}_tests".to_sym) do |task|
    task.pattern = "spec/#{test_type}/**/*_spec.rb"
    task.fail_on_error = true
    task.rspec_opts = '--format documentation'
  end
end

task test: %i[style unit_tests integration_tests]

task :deploy do
  # TODO: Deploy to Fargate here
end

task default: :test
