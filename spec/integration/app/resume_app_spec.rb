# frozen_string_literal: true

require 'spec_helper'

describe 'Given an app that renders resumes' do
  context 'When we access the app' do
    it 'It should be up' do
      uri = URI("http://#{ENV['DNS_RECORD_NAME']}.#{ENV['DNS_ZONE_NAME']}")
      response = Net::HTTP.get_response(uri)
      expect(response.code).to eq '200'
    end
  end
end
