require 'spec_helper'

describe 'ResumeApp' do
  include Rack::Test::Methods
  def app
    ResumeApp::Web::App
  end

  context 'Empty Markdown' do
    it 'Renders a page with no content' do
      expected_html = "\n"
      allow(ResumeApp::Downloaders)
        .to receive(:retrieve_latest_resume_as_markdown)
        .and_return('')

      get '/'

      expect(last_response.body).to eq(expected_html)
      expect(last_response.status).to eq 200
    end
  end

  context 'Some Markdown' do
    it 'Successfully converts Markdown into HTML' do
      test_markdown_content = <<-MARKDOWN
This is a document.
===================

A document can have many sections!
----------------------------------

It has words. Some of them are **bold,** and some of them are *emphasized.*
      MARKDOWN

      expected_html_content = <<-HTML
<h1 id="this-is-a-document">This is a document.</h1>\n
<h2 id="a-document-can-have-many-sections">A document can have many sections!</h2>\n
<p>It has words. Some of them are <strong>bold,</strong> and some of them are <em>emphasized.</em></p>
      HTML
      allow(ResumeApp::Downloaders)
        .to receive(:retrieve_latest_resume_as_markdown)
        .and_return(test_markdown_content)
      get '/'
      expect(last_response.body).to eq expected_html_content
      expect(last_response.status).to eq 200
    end
  end

  context 'AWS S3' do
    it 'Returns nil when no buckets could be found' do
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
      expect(last_response.status).to eq 500
      expect(last_response.body).to eq expected_response
    end
  end
end
