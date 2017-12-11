require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'
require 'dotenv'
require_relative 'lib/rake/helpers/aws/ecs.rb'

namespace :static_analysis do
  desc 'Run lint and style guide confirmation tests.'
  RuboCop::RakeTask.new(:style) do |task|
    task.options = ['-a']
  end
end

ENV['COVERAGE'] = 'true'
%w[unit integration].each do |test_type|
  namespace test_type.to_sym do
    Dotenv.load(".env.#{test_type}") if File.exist?(".env.#{test_type}")
    desc "Runs #{test_type} tests, along with setup and teardown procedures."

    task :setup do
      case test_type
      when 'integration'
        Rake::Task['deploy:generate_ecs_task'].invoke
        Rake::Task['deploy:deploy_ecs_task'].invoke
      end
    end

    task :teardown do
      case test_type
      when 'integration'
        Rake::Task['deploy:delete_ecs_task'].invoke
      end
    end

    RSpec::Core::RakeTask.new(:test) do |task|
      Rake::Task["#{test_type}:setup"].invoke
      task.pattern = "spec/#{test_type}/**/*_spec.rb"
      task.fail_on_error = true
      task.rspec_opts = '--format documentation'
      Rake::Task["#{test_type}:teardown"].invoke
    end
  end
end

namespace :deploy do
  task :generate_ecs_task do
    RakeHelpers::AWS::ECS.create_task_json_from_template!
  end

  task :deploy_ecs_task do
    RakeHelpers::AWS::ECS.deploy_ecs_task!
  end

  task :delete_ecs_task do
    RakeHelpers::AWS::ECS.delete_ecs_task!
  end
end

task test: %i[static_analysis:style unit:test integration:test]

task :deploy do
  # TODO: Deploy to Fargate here
end

task default: :test
