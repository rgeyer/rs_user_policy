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

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'helper'))

describe RsUserPolicy::Utilities do
  context :id_from_href do
    it 'can get id for an account' do
      RsUserPolicy::Utilities.id_from_href('/api/accounts/12345').should == '12345'
    end

    it 'can get id for a permission' do
      RsUserPolicy::Utilities.id_from_href('/api/permissions/12345').should == '12345'
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
      RsUserPolicy::Utilities.yield_on_keys_in_order(expectedCallOrder, testHash) do |role_title, href|
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
      RsUserPolicy::Utilities.yield_on_keys_in_order(['observer', 'admin', 'actor'], testHash) do |role_title, href|
        callOrder << role_title
      end
      callOrder[0].should == 'observer'
      callOrder.should == expectedCallOrder
    end

    it "Does not clobber source hash" do
      testHash = {
        'admin' => '/api/permission/1',
        'actor' => '/api/permission/2',
        'observer' => '/api/permission/3'
      }
      expectedCallOrder = ['observer','admin','actor']
      RsUserPolicy::Utilities.yield_on_keys_in_order(expectedCallOrder, testHash) do |role_title, href|
        # Do nothing
      end
      testHash.length.should == 3
      testHash.keys.should == ["admin","actor","observer"]
    end
  end

  context :yield_on_values_in_order do
    it 'yields to a block in the specified order' do
      testHash = {
        '/api/permission/1' => 'admin',
        '/api/permission/2' => 'admin',
        '/api/permission/3' => 'actor',
        '/api/permission/4' => 'actor',
        '/api/permission/5' => 'observer',
        '/api/permission/6' => 'observer'
      }
      expectedCallOrder = ['observer','admin','actor']
      callOrder = []
      RsUserPolicy::Utilities.yield_on_values_in_order(expectedCallOrder, testHash) do |href, role_title|
        callOrder << role_title
      end
      callOrder[0].should == 'observer'
      callOrder.should == ['observer','observer','admin','admin','actor','actor']
    end

    it 'yields non ordered values after specified values in order' do
      testHash = {
        '/api/permission/1' => 'admin',
        '/api/permission/2' => 'admin',
        '/api/permission/3' => 'actor',
        '/api/permission/4' => 'actor',
        '/api/permission/5' => 'observer',
        '/api/permission/6' => 'observer',
        '/api/permission/7' => 'billing',
        '/api/permission/8' => 'billing',
        '/api/permission/9' => 'enterprise_manager',
        '/api/permission/10' => 'enterprise_manager'
      }
      expectedCallOrder = [
        'observer',
        'observer',
        'admin',
        'admin',
        'actor',
        'actor',
        'billing',
        'billing',
        'enterprise_manager',
        'enterprise_manager'
      ]
      callOrder = []
      RsUserPolicy::Utilities.yield_on_values_in_order(['observer', 'admin', 'actor'], testHash) do |href, role_title|
        callOrder << role_title
      end
      callOrder[0].should == 'observer'
      callOrder.should == expectedCallOrder
    end

    it "Does not clobber source hash" do
      testHash = {
        '/api/permission/1' => 'admin',
        '/api/permission/2' => 'admin',
        '/api/permission/3' => 'actor',
        '/api/permission/4' => 'actor',
        '/api/permission/5' => 'observer',
        '/api/permission/6' => 'observer'
      }
      expectedCallOrder = ['observer','admin','actor']
      RsUserPolicy::Utilities.yield_on_keys_in_order(expectedCallOrder, testHash) do |href, role_title|
        # Do nothing
      end
      testHash.length.should == 6
      testHash.keys.should == [
        '/api/permission/1',
        '/api/permission/2',
        '/api/permission/3',
        '/api/permission/4',
        '/api/permission/5',
        '/api/permission/6'
      ]
    end
  end

  context :generate_compliant_password do
    it "Generates a compliant password" do
      pass = RsUserPolicy::Utilities.generate_compliant_password
      pass.should =~ /^(?=.*[^a-zA-Z])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@\#\$%\^&\*\(\)\-_=\+]).+$/
    end
  end
end