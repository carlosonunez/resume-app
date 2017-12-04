lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name           = 'resume_app'
  spec.version        = '20171204'
  spec.authors        = ['Carlos Nunez']
  spec.email          = ['dev@carlosnunez.me']
  spec.summary        = %q{A simple app that generates resumes from Markdown.}
  spec.description    = %q{A simple app that generates resumes from Markdown.}
  
  spec.files          = Dir.glob('lib/**/*').select { |file| /\.rb$/.match(file) }
  spec.executables    = ['bin/resume_app']
  spec.require_paths  = ['lib']
end
