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
        response = @ua.get
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
        
    end
    
    def add(doc, uri=nil, content_type=nil)
    
    end
    
    def update(doc, uri=nil, content_type=nil)
    
    end
    
    def delete(uri)
    
    end
    
    def commit()
    
    end
    
    def rollback()
    
    end
    
    def get(args)
    
    
    end
    
end
