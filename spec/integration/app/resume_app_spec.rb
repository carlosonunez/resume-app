# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes' do
  before(:all) do
    uri_string = "http://#{ENV['DNS_RECORD_NAME']}.#{ENV['DNS_ZONE_NAME']}"
    @app_uri = URI(uri_string)
    @pdf_uri = URI("#{uri_string}/pdf")
    @app_response = Net::HTTP.get_response(@app_uri)
    @pdf_response = Net::HTTP.get_response(@pdf_uri)
  end
  context 'When we access the app' do
    it 'It should be up' do
      expect(@app_response.code).to eq '200'
    end

    it 'It should produce the content that we expect' do
      expected_content = <<-CONTENT
<h1 id="my-name">My Name</h1>
<p>###### Small address here.</p>

<p>I\xE2\x80\x99m an awesome person. You should hire me.</p>

<h1 id="experience">Experience</h1>

<h2 id="job-1">Job 1</h2>
<p>###<em>Did a Thing</em>, <strong>From now until then</strong>###</p>

<ul>
  <li>Did this thing</li>
  <li>and that thing</li>
  <li>and even that thing that nobody wanted to do!</li>
</ul>
      CONTENT
      expect(@app_response.body.force_encoding('UTF-8')).to eq expected_content
    end

    it 'It should give us a PDF' do
      expect(@pdf_response.body[0, 4]).to eq '%PDF'
    end
  end
end
