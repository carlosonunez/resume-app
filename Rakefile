require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'

RuboCop::RakeTask.new(:style) do |task|
  task.options = ['-a']
end

ENV['COVERAGE'] = 'true'
RSpec::Core::RakeTask.new(:unit_tests) do |spec|
  spec.pattern = FileList['spec/unit/**/*_spec.rb']
  spec.rspec_opts = '--format documentation'
end

RSpec::Core::RakeTask.new(:integration_tests) do |spec|
  spec.pattern = FileList['spec/integration/**/*_spec.rb']
  spec.rspec_opts = '--format documentation'
end

task test: %i[style unit_tests integration_tests]

task :deploy do
  # TODO: Deploy to Fargate here
end

task default: :test
