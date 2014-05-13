Gem::Specification.new do |s|
  s.name        = 'dezi-client'
  s.version     = '1.1.1'
  s.date        = '2014-05-13'
  s.rubyforge_project = "nowarning"
  s.summary     = "Ruby client for the Dezi search engine"
  s.description = "Ruby client for the Dezi search engine. See http://dezi.org/"
  s.authors     = ["Peter Karman"]
  s.email       = 'karpet@dezi.org'
  s.homepage    = 'https://github.com/karpet/dezi-client-ruby'
  s.files       = ["lib/dezi/client.rb", "lib/dezi/doc.rb", "lib/dezi/response.rb"]
  s.license     = 'MIT'
  s.add_runtime_dependency "faraday", '~> 0'
  s.add_runtime_dependency "faraday_middleware", '~> 0'
  s.add_runtime_dependency "excon", '~> 0'
  s.add_runtime_dependency "hashie", '~> 0'
  s.add_runtime_dependency "mime-types", '~> 0'
  s.add_runtime_dependency "xml-simple", '~> 0'

end
