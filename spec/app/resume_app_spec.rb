require 'spec_helper'

describe 'Given an app that renders resumes' do
  include Rack::Test::Methods
  def app
    ResumeApp::Web::App
  end

  before(:each) do
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
Something bad happened: We couldn't find latest in bucket fake_bucket.
      DOC

      get '/'
      expect(last_response.body).to eq expected_response
      expect(last_response.status).to eq 500
    end
  end

  it 'Renders $S3_BUCKET_NAME/$RESUME_NAME if found and is valid Markdown' do
    stubbed_s3_client = Aws::S3::Client.new(stub_responses: true)
    allow(Aws::S3::Client)
      .to receive(:new)
      .and_return(stubbed_s3_client)
    stubbed_s3_client.stub_responses(:get_object, body: @test_markdown_content)

    get '/'
    expect(last_response.body).to eq @test_html_content
    expect(last_response.status).to eq 200
  end
end
