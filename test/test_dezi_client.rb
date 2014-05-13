require 'test/unit'
require 'pp'
require 'dezi/client'

# expects server running with 'dezi --no-auto_commit'

class DeziClientTest < Test::Unit::TestCase

  def test_dezi_client
    server_uri = ENV['DEZI_SERVER'] || 'http://localhost:5000'
    client = DeziClient.new(:username => 'foo', :password => 'bar', :server => server_uri)
    assert_equal( server_uri, client.server, "server hostname" )
    assert_equal( server_uri+'/search', client.search_uri, "search uri")

    resp = client.add('test/test.html')
    assert_equal( resp.is_success(), true, "add from filesystem" )

    html_doc = '<html><title>hello world</title><body>foo bar</body></html>'
    resp = client.add(html_doc, 'foo/bar.html')
    assert_equal( resp.is_success(), true, "add in-memory" )

    dezi_doc = DeziDoc.new(:uri => 'test/test-dezi-doc.xml')
    file = File.new(dezi_doc.uri, 'r')
    dezi_doc.content = file.read()
    file.close()
    resp = client.add(dezi_doc)
    assert_equal( resp.is_success(), true, "add dezi doc from filesystem" )
    
    dezi_doc2 = DeziDoc.new(:uri => 'auto/xml/magic')
    dezi_doc2.set_field(:title => 'ima dezi doc')
    dezi_doc2.set_field(:body  => 'hello world!')
    resp = client.add(dezi_doc2)
    assert_equal( resp.is_success(), true, "add dezi doc from memory" )

    resp = client.commit()
    assert_equal( resp.is_success(), true, "commit" )
    assert_equal( resp.status(), 200, "commit returns 200" )

    resp = client.delete('foo/bar.html')
    assert_equal( resp.is_success(), true, "delete doc" )

    resp = client.search('q' => 'dezi', 'x' => ['swishmime', 'swishencoding'])
    
    # debug
    #puts pp resp
    
    # iterate through results
    resp.results.each do |result|
        assert_not_nil( result.uri, "result has uri " + result.uri )
    end
    
    # metadata
    assert_equal( resp.total, 3, "got 3 results" )
    assert_match( /\d+\.\d+/, resp.search_time, "got search_time" )
    assert_match( /\d+\.\d+/, resp.build_time, "got build_time" )
    assert_equal( resp.query, "dezi", "query string roundtrip" )
    assert_not_nil( resp.suggestions, "got suggestions" )
    resp.suggestions.each do |term|
        puts "suggestion: #{term}"
    end
    
  end
    
end
