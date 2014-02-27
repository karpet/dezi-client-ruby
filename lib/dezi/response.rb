# DeziResponse is part of a Ruby client for the Dezi search platform.
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

class DeziResponse

    # most attributes are assigned dynamically in initialize().
    # Try:
    #  
    #  puts response.inspect
    #
    # to see them.
    
    attr_accessor :results
    
    def initialize(http_resp)
        @http_resp = http_resp
        
        #warn http_resp.headers.inspect
        #warn "code=" + http_resp.status.to_s
        
        @is_ok = false
        if (http_resp.status.to_s =~ /^2\d\d/)
            @is_ok = true
        end
        
        if (!@is_ok)
            return
        end
        
        #warn "is_ok=#{@is_ok}"
        
        body = http_resp.body
        
        #warn body.inspect
        
        # set body keys as attributes in the object
        body.each {|k,v|
        
            # results are special
            if k == 'results'
                next
            end
        
            # create the attribute
            self.instance_eval { class << self; self end }.send(:attr_accessor, k)
            
            # assign the value
            send("#{k}=",v)
        }
        
        if !body.has_key?('results')
            return
        end
        
        # make each result Hash into a DeziDoc object
        @results = []
        body['results'].each {|r|
            result = r
            result['fields'] = {}
            @fields.each {|f|
                result['fields'][f] = r.delete(f)
            }
        
            doc = DeziDoc.new(result)
            @results.push(doc)
        }
        
    end
    
    def status()
        return @http_resp.status
    end
    
    def is_success()
        return @is_ok
    end

end
