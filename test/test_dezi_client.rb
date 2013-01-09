require 'test/unit'
require 'dezi/client'

class DeziClientTest < Test::Unit::TestCase
  def test_initialize
    client = DeziClient.new()
    assert_equal 'http://localhost:5000',
        client.server
    assert_equal 'http://localhost:5000/search',
        client.search_uri
  end

end
