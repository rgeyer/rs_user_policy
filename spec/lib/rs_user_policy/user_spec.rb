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

describe RsUserPolicy::User do
  before(:all) do
    @user_email = 'email@foo.bar'
    @user_href = '/api/users/1234'
  end

  context :initialize do
    it "Sets email, href" do
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.email.should == @user_email
      user.href.should == @user_href
    end
  end

  context :email_accessor do
    it "Is readonly" do
      user = RsUserPolicy::User.new(@user_email, @user_href)
      lambda { user.email = "changed" }.should raise_error NoMethodError
    end
  end

  context :href_accessor do
    it "Is readonly" do
      user = RsUserPolicy::User.new(@user_email, @user_href)
      lambda { user.href = "changed" }.should raise_error NoMethodError
    end
  end

  context :add_permission do
    it "Can assign permissions" do
      permissions_src = flexmock(:role_title => "observer", :href => "hrefperm")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', permissions_src)
      permissions = user.get_api_permissions('/api/accounts/123')
      permissions.length.should == 1
      permissions.first.role_title.should == 'observer'
      permissions.first.href.should == 'hrefperm'
    end
  end

  context :get_api_permission do
    it "Returns an empty array if there is no record for the provided account href" do
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.get_api_permissions('/api/accounts/123').should == []
    end
  end

  context :clear_permissions do
    it "Honors dry_run" do
      observer_perm = flexmock(:role_title => "observer", :href => "hrefperm")
      admin_perm = flexmock(:role_title => "admin", :href => "hrefperm1")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', observer_perm)
      user.add_permission('/api/accounts/123', admin_perm)

      flexmock(RsUserPolicy::RightApi::PermissionUtilities).should_receive(:destroy_permissions).never()

      user.clear_permissions('/api/accounts/123', nil, :dry_run => true).should == {'hrefperm' => 'observer', 'hrefperm1' => 'admin'}
    end

    it "clears cached api permissions" do
      observer_perm = flexmock(:role_title => "observer", :href => "hrefperm")
      admin_perm = flexmock(:role_title => "admin", :href => "hrefperm1")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', observer_perm)
      user.add_permission('/api/accounts/123', admin_perm)

      flexmock(RsUserPolicy::RightApi::PermissionUtilities).should_receive(:destroy_permissions).once()

      user.clear_permissions('/api/accounts/123', nil)
      user.get_api_permissions('/api/accounts/123').should == []
    end
  end

  context :set_api_permissions do
    it "Removes all permissions if empty array is supplied" do
      permissions_src = flexmock(:role_title => "observer", :href => "hrefperm")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', permissions_src)
      flexmock(user).should_receive(:clear_permissions).once().and_return({'hrefperm' => 'observer'})

      removed,added = user.set_api_permissions([], '/api/accounts/123', nil)
      removed.should == {'hrefperm' => 'observer'}
      added.should == {}
    end

    it "Only adds permissions when desired permissions are a superset of current permissions" do
      permissions_src = flexmock(:role_title => "observer", :href => "hrefperm")
      client = flexmock(:permissions => flexmock(:index => [permissions_src]))
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', permissions_src)
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:destroy_permissions).
        once().
        with([], client).
        and_return({})
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:create_permissions).
        once().
        with(FlexMock.hsh(@user_href => {'admin' => nil}), client).
        and_return({@user_href => {'admin' => '/api/permissions/1'}})

      removed,added = user.set_api_permissions(['observer', 'admin'], '/api/accounts/123', client)
      removed.should == {}
      added.should == {'/api/permissions/1' => 'admin'}
    end

    it "Only removes permissions when desired permissions are a subset of current permissions" do
      observer_perm = flexmock(:role_title => "observer", :href => "hrefperm")
      admin_perm = flexmock(:role_title => "admin", :href => "hrefperm1")
      client = flexmock(:permissions => flexmock(:index => [observer_perm]))
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', observer_perm)
      user.add_permission('/api/accounts/123', admin_perm)

      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:create_permissions).
        once().
        with(FlexMock.hsh(@user_href => {}), client).
        and_return(@user_href => {})
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:destroy_permissions).
        once().
        with([admin_perm], client).
        and_return('hrefperm1' => 'admin')

      removed,added = user.set_api_permissions(['observer'], '/api/accounts/123', client)
      removed.should == {'hrefperm1' => 'admin'}
      added.should == {}
    end

    it "Both adds and removes when desired permissions require such" do
      observer_perm = flexmock(:role_title => "observer", :href => "hrefperm")
      admin_perm = flexmock(:role_title => "admin", :href => "hrefperm1")
      client = flexmock(:permissions => flexmock(:index => [observer_perm]))
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', observer_perm)
      user.add_permission('/api/accounts/123', admin_perm)

      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:create_permissions).
        once().
        with(FlexMock.hsh(@user_href => {'publisher' => nil}), client).
        and_return(@user_href => {'publisher' => '/api/permissions/1'})
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:destroy_permissions).
        once().
        with([admin_perm], client).
        and_return('hrefperm1' => 'admin')

      removed,added = user.set_api_permissions(['observer','publisher'], '/api/accounts/123', client)
      removed.should == {'hrefperm1' => 'admin'}
      added.should == {'/api/permissions/1' => 'publisher'}
    end

    it "Honors dry_run if empty array is supplied" do
      permissions_src = flexmock(:role_title => "observer", :href => "hrefperm")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', permissions_src)
      flexmock(user).should_receive(:clear_permissions).once().and_return({'hrefperm' => 'observer'})
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).should_receive(:destroy_permissions).never()

      removed,added = user.set_api_permissions([], '/api/accounts/123', nil, :dry_run => true)
      removed.should == {'hrefperm' => 'observer'}
      added.should == {}
    end

    it "Honors dry_run when desired permissions are a superset of current permissions" do
      permissions_src = flexmock(:role_title => "observer", :href => "hrefperm")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', permissions_src)
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:destroy_permissions).never()
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:create_permissions).never()

      removed,added = user.set_api_permissions(['observer', 'admin'], '/api/accounts/123', nil, :dry_run => true)
      removed.should == {}
      added.should == {1 => 'admin'}
    end

    it "Honors dry_run when desired permissions are a subset of current permissions" do
      observer_perm = flexmock(:role_title => "observer", :href => "hrefperm")
      admin_perm = flexmock(:role_title => "admin", :href => "hrefperm1")
      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', observer_perm)
      user.add_permission('/api/accounts/123', admin_perm)

      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:create_permissions).never()
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:destroy_permissions).never()

      removed,added = user.set_api_permissions(['observer'], '/api/accounts/123', nil, :dry_run => true)
      removed.should == {'hrefperm1' => 'admin'}
      added.should == {}
    end

    it "sets cached api permissions" do
      observer_perm = flexmock(:role_title => "observer", :href => "hrefperm")
      admin_perm = flexmock(:role_title => "admin", :href => "hrefperm1")
      client = flexmock(:permissions => flexmock(:index => [observer_perm]))

      user = RsUserPolicy::User.new(@user_email, @user_href)
      user.add_permission('/api/accounts/123', observer_perm)
      user.add_permission('/api/accounts/123', admin_perm)

      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:create_permissions).
        once().
        with(FlexMock.hsh(@user_href => {}), client).
        and_return(@user_href => {})
      flexmock(RsUserPolicy::RightApi::PermissionUtilities).
        should_receive(:destroy_permissions).
        once().
        with([admin_perm], client).
        and_return('hrefperm1' => 'admin')

      removed,added = user.set_api_permissions(['observer'], '/api/accounts/123', client)
      removed.should == {'hrefperm1' => 'admin'}
      added.should == {}
      user.get_api_permissions('/api/accounts/123').should == [observer_perm]
    end
  end
end