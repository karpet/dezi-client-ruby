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

## ChangeLog

1.1.1 - 2014-05-13
 - workaround Dezi server bug where 'fields' slot in response is null

1.1.0 - 2014-02-28
 - switch to Faraday http engine with multi-value param hack

1.0.0 - 2013-04-16
 - initial release
