require 'test/unit'
require 'dezi/client'

class DeziClientTest < Test::Unit::TestCase
  def test_initialize
    client = DeziClient.new()
    assert_equal( 'http://localhost:5000', client.server, "server hostname" )
    assert_equal( 'http://localhost:5000/search', client.search_uri, "search uri")
  end
  
  def test_filesystem
    client = DeziClient.new()
    resp = client.add('test/test.html')
    assert_equal( resp.is_success(), true, "add from filesystem" )
  end
  
  def test_in_memory
    client = DeziClient.new()
    html_doc = '<html><title>hello world</title><body>foo bar</body></html>'
    resp = client.add(html_doc, 'foo/bar.html')
    assert_equal( resp.is_success(), true, "add in-memory" )
  end
  
  def test_dezi_doc
    client = DeziClient.new()
    dezi_doc = DeziDoc.new(:uri => 't/test-dezi-doc.xml')
    file = File.new(dezi_doc.uri, 'r')
    dezi_doc.content = file.read()
    file.close()
    resp = client.add(dezi_doc)
    assert_equal( resp.is_succes(), true, "add dezi doc from filesystem" )
    
    dezi_doc2 = DeziDoc.new(:uri => 'auto/xml/magic')
    dezi_doc2.set_field(:title => 'ima dezi doc')
    dezi_doc2.set_field(:body  => 'hello world!')
    resp = client.add(dezi_doc2)
    assert_equal( resp.is_success(), true, "add dezi doc from memory" )
  end
  
  def test_commit
    client = DeziClient.new()
    resp = client.commit()
    assert_equal( resp.is_success(), true, "commit" )
    assert_equal( resp.status(), '200', "commit returns 200" )
  end
  
  def test_delete
    client = DeziClient.new()
    resp = client.delete('foo/bar.html')
    assert_equal( resp.is_success(), true, "delete doc" )
  end
  
  def test_search
    client = DeziClient.new()
    resp = client.search('q' => 'dezi')
    # debug
    puts resp.inspect
    
    # iterate through results
    resp.results.each do |result|
        assert_not_nil( result.uri, "result has uri " + result.uri )
    end
    
    # metadata
    assert_equal( resp.total, 3, "got 3 results" )
    assert_match( resp.search_time, /\d+\.\d+/, "got search_time" )
    assert_match( resp.build_time, /\d+\.\d+/, "got build_time" )
    assert_equal( resp.query, "dezi", "query string roundtrip" )
    assert_not_nil( resp.suggestions, "got suggestions" )
    resp.suggestions.each do |term|
        puts "suggestion: #{term}"
    end
    
  end
    
end
