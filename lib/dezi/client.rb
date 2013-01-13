# DeziClient is part of a Ruby client for the Dezi search platform.
# 
# Copyright 2013 by Peter Karman
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# dependencies
require 'rubygems'
require 'rest_client'
require 'json'

# related classes
require File.dirname(__FILE__) + '/response'
require File.dirname(__FILE__) + '/doc'

class DeziClient

    # attributes
    attr_accessor :server
    attr_accessor :about_server
    attr_accessor :search_uri
    attr_accessor :index_uri
    attr_accessor :commit_uri
    attr_accessor :rollback_uri
    attr_accessor :fields
    attr_accessor :facets
    attr_accessor :last_response
    attr_accessor :debug
    
    def initialize(server='http://localhost:5000', search='/search', index='/index', debug=false, username=false, password=false)
        @server = server
        @un = username
        @pw = password
        @debug = debug
        @ua = RestClient::Resource.new @server
        response = @ua.get :accept => :json
        if response.code != 200
            warn "Bad about response from server #{@server}: " . response.to_str
        end
        
        @about_server = JSON.parse(response.to_str)
        if @debug
            puts @about_server.inspect
        end
        
        @search_uri = @about_server['search']
        @index_uri  = @about_server['index']
        @commit_uri = @about_server['commit']
        @rollback_uri = @about_server['rollback']
        @fields     = @about_server['fields']
        @facets     = @about_server['facets']
        @searcher   = RestClient::Resource.new( @search_uri )
        @indexer    = RestClient::Resource.new( @index_uri, 
                :user => @un, :password => @pw, :accept => :json )
        
    end
    
    def _put_doc(doc, uri=nil, content_type=nil)
        body_buf = ""
        
        if (doc.is_a?('DeziDoc'))
            body_buf = doc.as_string()
            if (uri == nil)
                uri = doc.uri
            end
            if (content_type == nil)
                content_type = doc.mime_type
            end
            
        elsif (Pathname(doc).exist)
            file = File.new(doc, 'r')
            body_buf = file.read()
            if (uri == nil)
                uri = doc
            end
            
        else
            body_buf = doc
            if (uri == nil)
                raise "uri required"
            end
            
        end
        
        server_uri = '/' + uri
        if (self.debug)
            puts "uri=#{uri}"
            puts "body=#{body_buf}"
        end
        
        resp = self.indexer.post( server_uri, body_buf, 
            :content_type => content_type, :accept => :json )
            
        return DeziResponse.new(resp)
    end
    
    def add(doc, uri=nil, content_type=nil)
        return self._put_doc(doc, uri, content_type)
    end
    
    def update(doc, uri=nil, content_type=nil)
        return self._put_doc(doc, uri, content_type)
    end
    
    def delete(uri)
        resp = @indexer.delete(uri)
        return DeziResponse.new(resp)
    end
    
    def commit()
        ua = RestClient::Resource.new( @commit_uri, @un, @pw )
        resp = ua.post('/', :accept => :json)
        return DeziResponse.new(resp)
    end
    
    def rollback()
        ua = RestClient::Resource.new( @rollback_uri, @un, @pw )
        resp = ua.post('/', :accept => :json)
        return DeziResponse.new(resp)
    end
    
    def search(args)
        if (!args.has_key?("q"))
            raise "'q' param required"
        end
        
        resp = @searcher.get(args, :accept => :json)
        dr = DeziResponse.new(resp)
        if (!dr.is_success())
            @last_response = dr
            return false
        else
            return dr
        end
    
    end
    
end
