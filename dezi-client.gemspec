Gem::Specification.new do |s|
  s.name        = 'dezi-client'
  s.version     = '1.1.0'
  s.date        = '2014-02-28'
  s.rubyforge_project = "nowarning"
  s.summary     = "Ruby client for the Dezi search engine"
  s.description = "Ruby client for the Dezi search engine. See http://dezi.org/"
  s.authors     = ["Peter Karman"]
  s.email       = 'karpet@dezi.org'
  s.homepage    = 'https://github.com/karpet/dezi-client-ruby'
  s.files       = ["lib/dezi/client.rb", "lib/dezi/doc.rb", "lib/dezi/response.rb"]
  s.add_runtime_dependency "faraday"
  s.add_runtime_dependency "faraday_middleware"
  s.add_runtime_dependency "excon"
  s.add_runtime_dependency "mime-types"
  s.add_runtime_dependency "xml-simple"

end
