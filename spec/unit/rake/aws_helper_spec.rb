require 'spec_helper'
require_relative '../../../lib/rake/helpers/aws/ecs.rb'

describe 'Given a Rake helper that interfaces with ECS' do
  context 'When we generate a task JSON and when the template does not exist' do
    it 'It should tell us to provide the JSON template.' do
      allow(File)
        .to receive(:exist?)
        .and_return(false)
      expect { RakeHelpers::AWS::ECS.generate_task_json! }
        .to raise_error(IOError,
                        'ecs_task_template.json is missing. Please provide it.')
    end
  end
  context 'When we generate a task JSON and have missing env vars' do
    %w[
      S3_BUCKET_NAME
      AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY
    ].each do |required_env_var|
      it "It should fail when #{required_env_var} is missing." do
        old_env_var_value = ENV[required_env_var]
        ENV[required_env_var] = ''
        expect { RakeHelpers::AWS::ECS.generate_task_json! }
          .to raise_error(IOError,
                          "#{required_env_var} is missing. Please provide it.")
        ENV[required_env_var] = old_env_var_value
      end
    end
  end
end
