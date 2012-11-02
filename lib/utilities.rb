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

class Utilities

  # Uses a regex to parse a RightScale API resource id from it's relative href
  #
  # === Parameters
  # href(String):: The relative href of the RightScale API resource
  #
  # === Return
  # The resources ID
  def self.id_from_href(href)
    matches = /.*\/([0-9]*)/.match(href)
    matches[1] || nil
  end

  # Operates on the key/value pairs in a hash in the order specified in 'order'
  # followed by any key/value pairs not specified in the order
  #
  # === Parameters
  # order(Array):: An array containing keys in the order they should be yielded to the block
  # hash(Hash):: The hash to operate on in the specified order
  # block(Closure):: A closure to yield to
  def self.yield_on_keys_in_order(order, hash, &block)
    order.each do |key|
      if hash.key?(key)
        yield key, hash.delete(key)
      end
    end
    hash.each do |key,val|
      yield key, val
    end
  end

end