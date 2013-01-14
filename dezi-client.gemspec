Gem::Specification.new do |s|
  s.name        = 'dezi-client'
  s.version     = '1.0.0'
  s.date        = '2013-01-08'
  s.summary     = "Ruby client for the Dezi search engine"
  s.description = "Ruby client for the Dezi search engine"
  s.authors     = ["Peter Karman"]
  s.email       = 'karpet@dezi.org'
  s.homepage    = 'http://dezi.org'
  s.files       = ["lib/dezi/client.rb", "lib/dezi/doc.rb", "lib/dezi/response.rb"]
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "mime-types"
  s.add_runtime_dependency "xml-simple"

end
