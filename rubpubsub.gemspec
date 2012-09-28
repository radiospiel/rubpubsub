require "#{File.dirname(__FILE__)}/lib/rubpubsub/version.rb"

Gem::Specification.new do |gem|
  gem.name     = "rubpubsub"
  gem.version  = RubPubSub::VERSION
  
  gem.authors   = ["radiospiel"]
  gem.email     = ["eno@radiospiel.org"]
  gem.homepage  = "http://github.com/radiospiel/kibo"
  gem.summary   = "Everyone has a watchr - this one is mine."

  gem.description = gem.summary

  gem.add_dependency "sinatra"
  gem.add_dependency "expectation"
  gem.add_dependency "uuid"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
