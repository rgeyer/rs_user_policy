# Copyright (c) 2012 Ryan J. Geyer
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module RsUserPolicy
  class Utilities
    # Uses a regex to parse a RightScale API resource id from it's relative href
    #
    # @param [String] href The relative href of the RightScale API resource
    # @return [String] The unique ID of the resource
    def self.id_from_href(href)
      matches = /.*\/([0-9]*)/.match(href)
      matches[1] || nil
    end

    # Operates on the key/value pairs in a hash in the order specified in 'order'
    # followed by any key/value pairs not specified in the order
    #
    # @param [Array] order An array containing keys in the order they should be yielded to the block
    # @param [Hash] hash The hash to operate on in the specified order
    # @param [Closure] block A closure to yield to
    def self.yield_on_keys_in_order(order, hash, &block)
      order.each do |key|
        hash.select{|k,v| k == key}.each{|k,v| yield k,v }
      end
      hash.select{|k,v| !order.include?(k)}.each{|k,v| yield k,v}
    end

    # Operates on the key/value pairs in a hash in the order specified in 'order'
    # followed by any key/value pairs not specified in the order
    #
    # @param [Array] order An array containing values in the order they should be yielded to the block
    # @param [Hash] hash The hash to operate on in the specified order
    # @param [Closure] block A closure to yield to
    def self.yield_on_values_in_order(order, hash, &block)
      order.each do |value|
        hash.select{|k,v| v == value}.each{|k,v| yield k,v }
      end
      hash.select{|k,v| !order.include?(v) }.each{|k,v| yield k,v }
    end

  end
end