# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes' do
  context 'When we access the app' do
    it 'It should be up' do
      uri = URI(ENV['RESUME_APP_INTEGRATION_URL'])
      response = Net::HTTP.get(uri)
      expect(response.status).to eq 200
    end
  end
end
