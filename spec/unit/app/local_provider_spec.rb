# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes locally' do
  before(:all) do
    ENV['CLOUD_PROVIDER'] = 'local'
  end
  context 'When we fetch Markdown resumes locally' do
    it 'It fetches the correct Markdown document.' do
      allow(File)
        .to receive(:read)
        .with('RESUME.md')
        .and_return(@test_local_markdown_content)
      get '/'
      expect(last_response.body).to eq @test_local_html_content
      expect(last_response.status).to eq 200
    end
  end
end
