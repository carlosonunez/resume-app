# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes' do
  include Rack::Test::Methods
  def app
    ResumeApp::Web::App
  end

  before(:each) do
    ENV['S3_BUCKET_NAME'] = 'fake_bucket'
    ENV['RESUME_NAME'] = 'fake_resume'
    @test_local_markdown_content = <<-MARKDOWN
This document is stored locally.
===============================

No network access required!
MARKDOWN
    @test_local_html_content = <<-MARKDOWN
<h1 id="this-document-is-stored-locally">This document is stored locally.</h1>\n
<p>No network access required!</p>
MARKDOWN
    @test_markdown_content = <<-MARKDOWN
This is a document.
===================

A document can have many sections!
----------------------------------

It has words. Some of them are **bold,** and some of them are *emphasized.*
      MARKDOWN

    @test_html_content = <<-HTML
<h1 id="this-is-a-document">This is a document.</h1>\n
<h2 id="a-document-can-have-many-sections">A document can have many sections!</h2>\n
<p>It has words. Some of them are <strong>bold,</strong> and some of them are <em>emphasized.</em></p>
    HTML
  end

  context 'When we start the app' do
    it 'It responds to /ping' do
      get '/ping'
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq('Sup')
    end

    it 'Runs a web server' do
      expected_html = "\n"
      allow(ResumeApp::Downloaders)
        .to receive(:retrieve_latest_resume_as_markdown)
        .and_return('')

      get '/'
      expect(last_response.body).to eq(expected_html)
      expect(last_response.status).to eq 200
    end
  end

  context 'When we provide the app with a Markdown resume' do
    it 'Shows the converted Markdown as HTML' do
      allow(ResumeApp::Downloaders)
        .to receive(:retrieve_latest_resume_as_markdown)
        .and_return(@test_markdown_content)
      get '/'
      expect(last_response.body).to eq @test_html_content
      expect(last_response.status).to eq 200
    end
  end

  context 'When we fetch Markdown resumes locally' do
    it 'It fetches the correct Markdown document.' do
      file = double(File, read: @test_local_markdown_content)
      File.any_instance.stub(:read) { @test_local_markdown_content }
      ENV['CLOUD_PROVIDER'] = 'local'
      get '/'
      expect(last_response.body).to eq @test_local_html_content
      expect(last_response.status).to eq 200
    end
  end

  context 'When we fetch Markdown resumes from S3' do
    it 'Gives users an error when $S3_BUCKET_NAME/$RESUME_NAME was not found' do
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

    it 'Renders $S3_BUCKET_NAME/$RESUME_NAME if found and is valid Markdown' do
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

  context 'When we ask for a PDF' do
    it 'Gives us a PDF when we go to /pdf' do
      allow(ResumeApp::Downloaders)
        .to receive(:retrieve_latest_resume_as_markdown)
        .and_return(@test_markdown_content)
      get '/pdf'
      if last_response.body[0, 4] != '%PDF'
        puts "This is what we got: #{last_response.body}"
      end
      expect(last_response.body[0, 4]).to eq '%PDF'
      expect(last_response.status).to eq 200
    end
  end
end
