require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'colorize'
require 'dotenv'
Dir.glob('lib/rake/*.rake').each {|file| import file}

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

    task :setup do
      case test_type
      when integration
        Rake::Task["deploy:generate_ecs_task"].invoke
        Rake::Task["deploy:deploy_ecs_task"].invoke
      end
    end

    task :teardown do
      case test_type
      when integration
        Rake::Task["deploy:delete_ecs_task"].invoke
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
  end

  task :deploy_ecs_task do
  end

  task :delete_ecs_task do
  end
end

task test: %i[static_analysis:style unit:test integration:test]

task :deploy do
  # TODO: Deploy to Fargate here
end

task default: :test
