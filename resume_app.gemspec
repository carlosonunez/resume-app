# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resume_app/version'

Gem::Specification.new do |spec|
  spec.name           = 'resume_app'
  spec.version        = ResumeApp::VERSION
  spec.authors        = [ENV['GEM_AUTHOR']]
  spec.licenses	= ['MIT']
  spec.email          = [ENV['GEM_EMAIL']]
  spec.summary        = 'A simple app that generates resumes from Markdown.'
  spec.description    = 'A simple app that generates resumes from Markdown.'

  spec.files          = Dir.glob('lib/**/*').select { |file|
    /\.rb$/.match(file)
  }
  spec.executables    = ['resume_app']
  spec.require_paths  = ['lib']
end
