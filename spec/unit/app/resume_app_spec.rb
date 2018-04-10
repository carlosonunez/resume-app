# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes' do
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
