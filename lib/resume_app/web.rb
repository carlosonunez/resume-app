require 'resume_app/converters'
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
        markdown_from_s3 = '**Test Markdown**'
        ResumeApp::Converters.markdown_to_html(markdown_from_s3)
      end
    end
  end
end
