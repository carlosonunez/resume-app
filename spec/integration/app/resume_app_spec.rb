# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes' do
  context 'When we access the app' do
    before(:all) do
      app_uri = URI("http://#{ENV['DNS_RECORD_NAME']}.#{ENV['DNS_ZONE_NAME']}")
    end
    it 'It should be up' do
      response = Net::HTTP.get_response(app_uri)
      expect(response.code).to eq '200'
    end

    it 'Should produce the content that we expect' do
      expected_content = <<-CONTENT
<h1 id="my-name">My Name</h1>
<p>###### Small address here.</p>

<p>I’m an awesome person. You should hire me.</p>

<h1 id="experience">Experience</h1>

<h2 id="job-1">Job 1</h2>
<p>###<em>Did a Thing</em>, <strong>From now until then</strong>###</p>

<ul>
  <li>Did this thing</li>
  <li>and that thing</li>
  <li>and even that thing that nobody wanted to do!</li>
</ul>
      CONTENT
      body = Net::HTTP.get(app_uri)
      expect(body).to eq expected_content
    end
  end
end
