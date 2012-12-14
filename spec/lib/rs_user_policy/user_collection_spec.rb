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

describe RsUserPolicy::UserCollection do
  context :add_users do
    it "Creates a hash with the user href as the key, and a hash with the email and href as the value" do
      users_src = [flexmock(:email => 'foo@bar.baz', :href => 'hrefhere')]
      usercol = RsUserPolicy::UserCollection.new
      usercol.users.length.should == 0
      usercol.add_users(users_src)
      usercol.users.length.should == 1
    end

    it "Does not clobber existing users" do
      users_src = [flexmock(:email => 'foo@bar.baz', :href => 'hrefhere')]
      usercol = RsUserPolicy::UserCollection.new
      usercol.add_users(users_src)

      usercol.users.length.should == 1
      usercol["hrefhere"].email.should == 'foo@bar.baz'
      usercol["hrefhere"].href.should == 'hrefhere'
      usercol["hrefhere"].get_api_permissions('accthref').should == []

      usercol["hrefhere"].add_permission('accthref', flexmock(:role_title => 'observer', :href => 'permhref'))
      usercol.add_users(users_src)

      usercol.users.length.should == 1
      permissions = usercol["hrefhere"].get_api_permissions('accthref')
      permissions.length.should == 1
      permissions.first.role_title.should == 'observer'
      permissions.first.href.should == 'permhref'
    end
  end

  context :add_permissions do
    it "Can assign permissions" do
      users_src = [flexmock(:email => 'foo@bar.baz', :href => 'hrefhere')]
      permissions_src = [flexmock(:user => users_src.first, :role_title => "observer", :href => "hrefperm")]
      usercol = RsUserPolicy::UserCollection.new
      usercol.add_users(users_src)
      usercol.add_permissions('/api/accounts/123', permissions_src)
      usercol["hrefhere"].get_api_permissions('/api/accounts/123').length.should == 1
    end

    it "Can assign permissions to a user who isn't already in existence" do
      users_src = [flexmock(:email => 'foo@bar.baz', :href => 'hrefhere')]
      permissions_src = [flexmock(
          :user => flexmock(:email => 'foo1@bar.baz', :href => 'hreftwo'),
          :role_title => "observer",
          :href => "hrefperm"
        )
      ]
      usercol = RsUserPolicy::UserCollection.new
      usercol.add_users(users_src)
      usercol.add_permissions('/api/accounts/123', permissions_src)
      usercol.users.length.should == 2
      usercol["hreftwo"].should_not == nil
      permissions = usercol["hreftwo"].get_api_permissions('/api/accounts/123')
      permissions.length.should == 1
      permissions.first.role_title.should == 'observer'
      permissions.first.href.should == 'hrefperm'
    end
  end

  context :users do
    it "Return an array of RsUserPolicy::User" do
      users_src = [flexmock(:email => 'foo@bar.baz', :href => 'hrefhere')]
      usercol = RsUserPolicy::UserCollection.new
      usercol.add_users(users_src)
      usercol.users.class.should == Array
      usercol.users.first.class.should == RsUserPolicy::User
    end
  end
end