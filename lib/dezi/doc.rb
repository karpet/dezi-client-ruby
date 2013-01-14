# DeziDoc is part of a Ruby client for the Dezi search platform.
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

require 'rubygems'
require 'xmlsimple'

class DeziDoc

    attr_accessor   :mime_type
    attr_accessor   :summary
    attr_accessor   :title
    attr_accessor   :content
    attr_accessor   :uri
    attr_accessor   :mtime
    attr_accessor   :size
    attr_accessor   :score
    attr_accessor   :fields
    
    def initialize(args)
        args.each {|k,v| send("#{k}=",v)}
        @fields = {}
    end
    
    def set_field(args)
        args.each {|k,v| @fields[k] = v}
        @mime_type = 'application/xml'
    end
    
    def get_field(fname)
        if @fields.has_key?(fname)
            return @fields[fname]
        else
            return nil
        end
    end
    
    def as_string()
        #puts "fields.length=" + @fields.length.to_s
        if @fields.length > 0
            return self.as_xml()
        else
            return @content
        end
    end
    
    def as_xml()
        return XmlSimple.xml_out(@fields, {'rootname' => 'doc', 'noattr' => true})
    end

end
