require 'spec_helper'

describe 'GET' do
  include Rack::Test::Methods
  def app
    ResumeApp
  end

  context 'No content' do
    it "displays a page with no content" do
      obj.stub(:generate_html_from_markdown) { '' }
      get '/'

      expect(last_response.body).to eq('')
      expect(last_response.status).to eq 200
    end
  end

  context 'Render Markdown into HTML' do
    it "turns Markdown into HTML" do
      expected_markdown = <<-MARKDOWN
I am a document
===============

This is a document. Bow down before my documentiness.
      MARKDOWN

      expected_html = <<-HTML
<html>
<body>
<h1>I am a document</h1>
<p>This is a document. Bow down before my documentiness.</p>
</body>
      HTML
      allow(File).to receive(:read).and_return(expected_markdown)
      get '/'

      expect(last_response.body).to eq(expected_html)
      expect(last_response.code).to eq 200
    end
  end
end
