require 'spec_helper'
require_relative '../../../lib/rake/helpers/aws/ecs.rb'

describe 'Given a Rake helper that interfaces with ECS' do
  context 'When we generate a task JSON and when the template does not exist' do
    it 'It should tell us to provide the JSON template.' do
      allow(File)
        .to receive(:exist?)
        .and_return(false)
      expect {RakeHelpers::AWS::ECS.generate_task_json!}
        .to raise_error(IOError, "ecs_task_template.json is missing. Please provide it.")
    end
  end
  context "When we generate a task JSON and have missing environment variables" do
    ['S3_BUCKET_NAME','RESUME_NAME'].each do |required_env_var|
      it "It should fail when #{required_env_var} is missing." do
        allow(ENV)
          .to receive(:[])
          .with("#{required_env_var}")
          .and_return("")
        expect {RakeHelpers::AWS::ECS.generate_task_json!}
          .to raise_error(IOError, "#{required_env_var} is missing. Please provide it.")
      end
    end
  end
end
