# frozen_string_literal: true

require 'resume_app/converters'
require 'resume_app/downloaders'
require 'sinatra'

# ResumeApp
module ResumeApp
  # This contains the actual web app along with its routes.
  # I chose to use Sinatra because it is super-lightweight and super-easy
  # to get going with.
  module Web
    # This is the web app!
    class App < Sinatra::Base
      set :show_exceptions, false
      set :bind, '0.0.0.0'
      error do
        e = env['sinatra.error']
        "Something bad happened: #{e.message}."
      end

      get '/' do
        latest_resume = Downloaders.retrieve_latest_resume_as_markdown
        Converters.markdown_to_html(latest_resume)
      end

      get '/ping' do
        'Sup'
      end

      get '/pdf' do
        content_type 'application/pdf'
        latest_resume_as_markdown =
          Downloaders.retrieve_latest_resume_as_markdown
        Converters.markdown_to_pdf(latest_resume_as_markdown)
      end
    end
  end
end
