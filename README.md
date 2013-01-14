dezi-client-ruby
================

Ruby client for Dezi search server

Example:

 require 'dezi/client'

 # create a client
 client = DeziClient.new(:username => 'foo', :password => 'bar')

 # add some content
 resp   = client.add('some/path.html')
 if !resp.is_success
     raise "failed to add some/path.html"
 end

 # search for content
 resp = client.search('q' => 'some')
 resp.results.each do |result|
     puts "found #{result.uri}"
 end

See http://dezi.org/


