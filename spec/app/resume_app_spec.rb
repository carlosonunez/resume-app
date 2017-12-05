require 'spec_helper'

describe 'ResumeApp' do
  include Rack::Test::Methods
  def app
    ResumeApp::Web::App
  end

  context 'Empty Markdown' do
    it "Renders a page with no content" do
      expected_html = "\n"
      allow(ResumeApp::Downloaders)
        .to receive(:retrieve_latest_resume_from_s3)
        .and_return('')
      
      get '/'

      expect(last_response.body).to eq(expected_html)
      expect(last_response.status).to eq 200
    end
  end

  context 'Some Markdown' do
    it "Successfully converts Markdown into HTML" do
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
        .to receive(:retrieve_latest_resume_from_s3)
        .and_return(test_markdown_content)
      get '/'
      expect(last_response.body).to eq expected_html_content
      expect(last_response.status).to eq 200
    end
  end
end
