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

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

require 'utilities'

describe Utilities do
  context :id_from_href do
    it 'can get id for an account' do
      Utilities.id_from_href('/api/accounts/12345').should == '12345'
    end

    it 'can get id for a permission' do
      Utilities.id_from_href('/api/permissions/12345').should == '12345'
    end
  end

  context :yield_on_keys_in_order do
    it 'yields to a block in the specified order' do
      testHash = {
        'admin' => '/api/permission/1',
        'actor' => '/api/permission/2',
        'observer' => '/api/permission/3'
      }
      expectedCallOrder = ['observer','admin','actor']
      callOrder = []
      Utilities.yield_on_keys_in_order(expectedCallOrder, testHash) do |role_title, href|
        callOrder << role_title
      end
      callOrder[0].should == 'observer'
      callOrder.should == expectedCallOrder
    end

    it 'yields non ordered keys after specified keys in order' do
      testHash = {
        'admin' => '/api/permission/1',
        'actor' => '/api/permission/2',
        'observer' => '/api/permission/3',
        'billing' => '/api/permission/4',
        'enterprise_manager' => '/api/permission/5'
      }
      expectedCallOrder = ['observer','admin','actor', 'billing', 'enterprise_manager']
      callOrder = []
      Utilities.yield_on_keys_in_order(['observer', 'admin', 'actor'], testHash) do |role_title, href|
        callOrder << role_title
      end
      callOrder[0].should == 'observer'
      callOrder.should == expectedCallOrder
    end
  end
end