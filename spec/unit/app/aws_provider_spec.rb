# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes from AWS S3' do
  before(:all) do
    ENV['CLOUD_PROVIDER'] = 'AWS'
    ENV['S3_BUCKET_NAME'] = 'fake_bucket'
    ENV['RESUME_NAME'] = 'fake_resume'
  end
  context 'When we fetch Markdown resumes from it' do
    it 'It gives users an error when the resume was not found' do
      stubbed_s3_client = Aws::S3::Client.new(stub_responses: true)
      allow(Aws::S3::Client)
        .to receive(:new)
        .and_return(stubbed_s3_client)
      stubbed_s3_client.stub_responses(
        :get_object,
        Aws::S3::Errors::NoSuchKey.new('test', 'test')
      )

      expected_response = <<-DOC.tr("\n", ' ').strip
Something bad happened: We couldn't find #{ENV['RESUME_NAME']} in
bucket #{ENV['S3_BUCKET_NAME']}.
      DOC

      get '/'
      expect(last_response.body).to eq expected_response
      expect(last_response.status).to eq 500
    end

    it 'It renders the resume if found and is valid Markdown' do
      stubbed_s3_client = Aws::S3::Client.new(stub_responses: true)
      allow(Aws::S3::Client)
        .to receive(:new)
        .and_return(stubbed_s3_client)
      stubbed_s3_client.stub_responses(:get_object,
                                       body: @test_markdown_content)
      get '/'
      expect(last_response.body).to eq @test_html_content
      expect(last_response.status).to eq 200
    end
  end
end
