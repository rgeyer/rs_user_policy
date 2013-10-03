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

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'helper'))
require 'right_api_client'

# TODO: This could use an integration test
describe RsUserPolicy::RightApi::MultiClient do

  context :length do
    it "returns the number of accounts" do
      client1 = flexmock("client")
      client1.should_receive(:child_accounts).once.and_raise(RightApi::ApiError.new flexmock("request"), flexmock(:code => 402, :body => "Permission denied"))
      client1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).once.and_return(client1)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234])
      multi_client.length.should == 1
    end
  end

  context :size do
    it "returns the number of accounts" do
      client1 = flexmock("client")
      client1.should_receive(:child_accounts).once.and_raise(RightApi::ApiError.new flexmock("request"), flexmock(:code => 402, :body => "Permission denied"))
      client1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).once.and_return(client1)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234])
      multi_client.size.should == 1
    end
  end

  context :array_accessor do
    it "returns the specified account" do
      client1 = flexmock("client")
      client1.should_receive(:child_accounts).once.and_raise(RightApi::ApiError.new flexmock("request"), flexmock(:code => 402, :body => "Permission denied"))
      client1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).once.and_return(client1)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234])
      multi_client.size.should == 1
      multi_client[1234][:has_children].should == false
    end
  end

  context :initialize do
    it "handles a single non enterprise account" do
      client1 = flexmock("client")
      client1.should_receive(:child_accounts).once.and_raise(RightApi::ApiError.new flexmock("request"), flexmock(:code => 402, :body => "Permission denied"))
      client1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).once.and_return(client1)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234])
      multi_client.length.should == 1
      keys = []
      multi_client.each do |account_id,account|
        keys << account_id
      end
      keys.should == [1234]
      multi_client[1234][:has_children].should == false
    end

    it "handles many non enterprise accounts" do
      client1 = flexmock("client")
      client1.should_receive(:child_accounts).twice.and_raise(RightApi::ApiError.new flexmock("request"), flexmock(:code => 402, :body => "Permission denied"))
      client1.should_receive(:accounts).twice.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).times(2).and_return(client1,client1)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234,5678])
      multi_client.length.should == 2
      keys = []
      multi_client.each do |account_id,account|
        keys << account_id
      end
      keys.should == [1234,5678]
      multi_client[1234][:has_children].should == false
      multi_client[5678][:has_children].should == false
    end

    it "handles a single enterprise account with one child" do
      client1 = flexmock("client")
      client2 = flexmock("client2")
      client2.should_receive(:href).and_return("/api/accounts/5678")
      client1.should_receive(:child_accounts).once.and_return(flexmock(:index => [client2]))
      client1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).times(2).and_return(client1,nil)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234])
      multi_client.length.should == 2
      keys = []
      multi_client.each do |account_id,account|
        keys << account_id
      end
      keys.should == [5678,1234]
      multi_client[1234][:has_children].should == true
      multi_client[5678][:has_children].should == false
      multi_client[5678][:parent].should == 1234
    end

    it "handles a single enterprise account with many children" do
      client1 = flexmock("client1")
      client2 = flexmock("client2")
      client3 = flexmock("client3")
      client4 = flexmock("client4")
      client2.should_receive(:href).and_return("/api/accounts/5678")
      client3.should_receive(:href).and_return("/api/accounts/9101")
      client4.should_receive(:href).and_return("/api/accounts/1213")
      client1.should_receive(:child_accounts).once.and_return(flexmock(:index => [client2,client3,client4]))
      client1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).times(4).and_return(client1,nil,nil,nil)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234])
      multi_client.length.should == 4
      keys = []
      multi_client.each do |account_id,account|
        keys << account_id
      end
      keys.should == [5678,9101,1213,1234]
      multi_client[1234][:has_children].should == true
      multi_client[5678][:has_children].should == false
      multi_client[5678][:parent].should == 1234
      multi_client[9101][:has_children].should == false
      multi_client[9101][:parent].should == 1234
      multi_client[1213][:has_children].should == false
      multi_client[1213][:parent].should == 1234
    end

    it "handles many enterprise accounts with one child each" do
      ent1 = flexmock("ent1")
      ent2 = flexmock("ent2")
      client1 = flexmock("client1")
      client2 = flexmock("client2")
      client1.should_receive(:href).and_return("/api/accounts/9101")
      client2.should_receive(:href).and_return("/api/accounts/1213")
      ent1.should_receive(:child_accounts).once.and_return(flexmock(:index => [client1]))
      ent2.should_receive(:child_accounts).once.and_return(flexmock(:index => [client2]))
      ent1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      ent2.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).times(4).and_return(ent1,nil,ent2,nil)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234,5678])
      multi_client.length.should == 4
      keys = []
      multi_client.each do |account_id,account|
        keys << account_id
      end
      keys.should == [9101,1234,1213,5678]
      multi_client[1234][:has_children].should == true
      multi_client[9101][:parent].should == 1234
      multi_client[5678][:has_children].should == true
      multi_client[1213][:parent].should == 5678
    end

    it "handles many enterprise accounts with many child each" do
      ent1 = flexmock("ent1")
      ent2 = flexmock("ent2")
      client1 = flexmock("client1")
      client2 = flexmock("client2")
      client3 = flexmock("client3")
      client4 = flexmock("client4")
      client1.should_receive(:href).and_return("/api/accounts/9101")
      client2.should_receive(:href).and_return("/api/accounts/1213")
      client3.should_receive(:href).and_return("/api/accounts/1415")
      client4.should_receive(:href).and_return("/api/accounts/1617")
      ent1.should_receive(:child_accounts).once.and_return(flexmock(:index => [client1,client3]))
      ent2.should_receive(:child_accounts).once.and_return(flexmock(:index => [client2,client4]))
      ent1.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      ent2.should_receive(:accounts).once.and_return(flexmock(:show => ""))
      flexmock(RightApi::Client).should_receive(:new).times(6).and_return(ent1,nil,nil,ent2,nil,nil)

      multi_client = RsUserPolicy::RightApi::MultiClient.new('foo@bar.baz', 'password', [1234,5678])
      multi_client.length.should == 6
      keys = []
      multi_client.each do |account_id,account|
        keys << account_id
      end
      keys.should == [9101,1415,1234,1213,1617,5678]
      multi_client[1234][:has_children].should == true
      multi_client[9101][:parent].should == 1234
      multi_client[1415][:parent].should == 1234
      multi_client[5678][:has_children].should == true
      multi_client[1213][:parent].should == 5678
      multi_client[1617][:parent].should == 5678
    end
  end
end