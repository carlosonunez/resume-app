require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'

RuboCop::RakeTask.new(:style) do |task|
  task.options = ['-a']
end

ENV['COVERAGE'] = 'true'
RSpec::Core::RakeTask.new(:unit_tests) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task test: %i[style unit_tests]

task :deploy do
  # TODO: Deploy to Fargate here
end

task default: :test
