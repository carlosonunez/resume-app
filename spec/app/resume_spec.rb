require 'spec_helper'
require 'rack/test'
require_relative '../../app.rb'

RSpec.describe ResumeApp do
  include Rack::Test::Methods
  def app
    ResumeApp
  end
end

describe 'GET' do
  context 'No content' do
    get '/'

    expect(last_response.body).to eq('')
    expect(last_response.status).to eq 200
  end
end
