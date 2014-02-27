# DeziClient is a Ruby client for the Dezi search platform.
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
require 'faraday_middleware'
require 'uri'
require 'json'
require 'pathname'
require 'mime/types'

# related classes
require File.dirname(__FILE__) + '/response'
require File.dirname(__FILE__) + '/doc'

# DeziClient is a Ruby client for indexing and searching documents
# with the Dezi REST search platform. See http://dezi.org/ for details
# on the server.
#
# See the test/test_dezi_client.rb for full example.
#
# Usage:
#
#  client = DeziClient.new(
#       :server     => 'http://localhost:5000',
#       :username   => 'foo',
#       :password   => 'secret',
#  )
#
#  doc = 'some/path/file.html'
#  response = client.add(doc)   # DeziResponse returned
#  if !response.is_success
#     raise "Failed to add #{doc} to server"
#  end
#
#  # if Dezi server has auto_commit==false
#  # then must call commit()
#  client.commit()
#
#  response = client.search('q' => 'search string')  # DeziResponse returned
#  if !response.is_success
#     raise "Failed to search"
#  end
#
#  response.results.each |result|
#     puts "result: #{result.uri}"
#  end
#
# Related classes: DeziResponse and DeziDoc
#

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
    attr_accessor :user_agent
    
    def version
        return "1.1.0"
    end

    def connection(uri)
        opts = { 
            :url => uri,
            :headers => {
                 'User-Agent'   => @user_agent,
                 'Accept'       => 'application/json'
            }   
        }   
        conn = Faraday.new(opts) do |faraday|
            faraday.request :url_encoded
            [:mashify, :json, :raise_error].each{|mw| faraday.response(mw) }
            faraday.response :logger if @debug
            faraday.adapter  :excon
        end 

        if (@un && @pw)
            conn.request :basic_auth, @un, @pw
        end

        return conn
    end
 
    def initialize(args)
        @debug = ENV['DEZI_DEBUG']
        
        if (args.has_key? :server)
            @server = args[:server]
        else 
            @server = 'http://localhost:5000'
        end

        # sanity check
        begin
            uri = URI.parse(@server)
        rescue URI::InvalidURIError => err
            raise "Bad :server value " + err
        end
        if (!uri.host || !uri.port)
            raise "Bad :server value " + @server
        end
        
        if (args.has_key? :username and args.has_key? :password)
            @un = args[:username]
            @pw = args[:password]
        end
        
        if (args.has_key? :user_agent)
            @user_agent = args[:user_agent]
        else
            @user_agent = 'dezi-client-ruby/'+version()
        end
        
        if (args.has_key? :search and args.has_key? :index)
            @search_uri = @server + args[:search]
            @index_uri  = @server + args[:index]
        else
            conn = connection(@server)
            response = conn.get '/'

            if response.status != 200
                raise "Bad about response from server #{@server}: " . response.body
            end
            @about_server = response.body
            if @debug
                puts @about_server.inspect
            end
        
            @search_uri   = @about_server['search']
            @index_uri    = @about_server['index']
            @commit_uri   = @about_server['commit']
            @rollback_uri = @about_server['rollback']
            @fields       = @about_server['fields']
            @facets       = @about_server['facets']
        end
        
        @searcher = connection( @search_uri )
        
    end
    
    private
    
    def _put_doc(doc, uri=nil, content_type=nil)
        body_buf = ""
                
        if (doc.is_a?(DeziDoc))
            body_buf = doc.as_string()
            if (uri == nil)
                uri = doc.uri
            end
            if (content_type == nil)
                content_type = doc.mime_type
            end
            
        elsif (Pathname.new(doc).exist?)
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
        
        if (!content_type or !content_type.length)
            content_type = MIME::Types.type_for(uri)[0]
        end
        
        server_uri = '/' + uri
        if (@debug)
            puts "uri=#{uri}"
            puts "body=#{body_buf}"
            puts "content_type="#{content_type}"
        end
        
        conn = connection(@index_uri)
        resp = conn.post do |req|
            req.url @index_uri + server_uri
            req.body = body_buf
            req.headers['Content-Type'] = content_type
        end
            
        return DeziResponse.new(resp)
    end
    
    public

    # add() takes an initial argument of "doc" which can be a DeziDoc object,
    # a string representing a Pathname, or a string representing the content of a document.
    # If "doc" represents the content of a document, additional arguments
    # "uri" and "content_type" are required.
    
    def add(doc, uri=nil, content_type=nil)
        return _put_doc(doc, uri, content_type)
    end
    
    # update() takes an initial argument of "doc" which can be a DeziDoc object,
    # a string representing a Pathname, or a string representing the content of a document.
    # If "doc" represents the content of a document, additional arguments
    # "uri" and "content_type" are required.
    
    def update(doc, uri=nil, content_type=nil)
        return _put_doc(doc, uri, content_type)
    end
    
    def delete(uri)
        doc_uri = @index_uri + '/' + uri
        conn = connection(doc_uri)
        resp = conn.delete()
        return DeziResponse.new(resp)
    end
    
    # commit() and rollback() are only relevant if the Dezi server
    # has "auto_commit" turned off.
     
    def commit()
        conn = connection(@commit_uri)
        resp = conn.post(@commit_uri)
        return DeziResponse.new(resp)
    end
    
    # commit() and rollback() are only relevant if the Dezi server
    # has "auto_commit" turned off.
    
    def rollback()
        conn = connection(@rollback_uri)
        resp = conn.post(@rollback_uri)
        return DeziResponse.new(resp)
    end
    
    def search(params)
        if (!params.has_key?("q"))
            raise "'q' param required"
        end
        
        resp = @searcher.get @search_uri, params
        dr = DeziResponse.new(resp)
        if (!dr.is_success())
            @last_response = dr
            return false
        else
            return dr
        end
    
    end
    
end
