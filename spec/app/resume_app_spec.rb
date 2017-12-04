require 'spec_helper'

describe 'ResumeApp' do
  include Rack::Test::Methods
  def app
    ResumeApp::Web::App
  end

  context 'Empty Markdown' do
    it "Renders a page with no content" do
      expected_html = ''
      allow(ResumeApp::Converters).to receive(:markdown_to_html).and_return(expected_html)
      
      get '/'

      expect(last_response.body).to eq('')
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
<html>
<body>
<p><h1>This is a document.</h1></p>
<p><h2>A document can have many sections!</h2></p>
<p>It has words. Some of them are <strong>bold,</strong> and some of them are <em>emphasized.</em>
</body>
</html>
      HTML
      allow(ResumeApp::Converters)
        .to receive(:markdown_to_html)
        .with(test_markdown_content)
      get '/'
      expect(last_response.body).to eq expected_html_content
      expect(last_response.status).to eq 200
    end
  end
end
