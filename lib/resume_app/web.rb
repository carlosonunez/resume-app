require 'resume_app/converters'
require 'resume_app/downloaders'
require 'sinatra'

module ResumeApp
  module Web
    class App < Sinatra::Base
      set :show_exceptions, false
      error do
        e = env['sinatra.error']
        "Something bad happened: #{e.message}." 
      end

      get '/' do
        latest_resume = Downloaders.retrieve_latest_resume_from_s3()
        Converters.markdown_to_html(latest_resume)
      end
    end
  end
end
