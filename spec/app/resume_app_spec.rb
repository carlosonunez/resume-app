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
end
