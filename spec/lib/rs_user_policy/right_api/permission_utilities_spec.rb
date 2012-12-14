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

describe RsUserPolicy::RightApi::PermissionUtilities do
  context :destroy_permissions do
    it "destroys all permissions in order" do
      client = flexmock("client")
      client.should_receive(:permissions).with(
        FlexMock.hsh(:id => "1")
      ).and_return(flexmock(:destroy => ''))
      client.should_receive(:permissions).with(
        FlexMock.hsh(:id => "2")
      ).and_return(flexmock(:destroy => ''))
      client.should_receive(:permissions).with(
        FlexMock.hsh(:id => "3")
      ).and_return(flexmock(:destroy => ''))
      client.should_receive(:permissions).with(
        FlexMock.hsh(:id => "4")
      ).and_return(flexmock(:destroy => ''))

      permissions = [
        flexmock(:role_title => "observer", :href => "/api/permission/4"),
        flexmock(:role_title => "actor", :href => "/api/permission/1"),
        flexmock(:role_title => "publisher", :href => "/api/permission/3"),
        flexmock(:role_title => "observer", :href => "/api/permission/2")
      ]
      RsUserPolicy::RightApi::PermissionUtilities.destroy_permissions(permissions, client)
    end
  end

  context :create_permissions do
    it "creates one users permissions in order" do
      client = flexmock("client")
      permissions = flexmock("permissions")
      created_permission = flexmock(:href => '/api/permissions/123')
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'observer'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'actor'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'publisher'
      ).and_return(created_permission)
      client.should_receive(:permissions).times(3).and_return(permissions)

      user_permissions = {
        '/api/users/123' => {'actor' => nil, 'publisher' => nil, 'observer' => nil}
      }
      RsUserPolicy::RightApi::PermissionUtilities.create_permissions(user_permissions, client)
    end

    it "creates many users permissions in order" do
      client = flexmock("client")
      permissions = flexmock("permissions")
      created_permission = flexmock(:href => '/api/permissions/123')
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'observer'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'actor'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'publisher'
      ).and_return(created_permission)


      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/1234', 'permission[role_title]' => 'observer'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/1234', 'permission[role_title]' => 'publisher'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/1234', 'permission[role_title]' => 'admin'
      ).and_return(created_permission)
      client.should_receive(:permissions).times(6).and_return(permissions)

      user_permissions = {
        '/api/users/123' => {'actor' => nil, 'publisher' => nil, 'observer' => nil},
        '/api/users/1234' => {'publisher' => nil, 'observer' => nil, 'admin' => nil}
      }
      RsUserPolicy::RightApi::PermissionUtilities.create_permissions(user_permissions, client)
    end

    it "returns permissions input parameter with created permission hrefs" do
      client = flexmock("client")
      permissions = flexmock("permissions")
      created_permission = flexmock("created_permission")
      created_permission.should_receive(:href).times(6).and_return(
        '/api/permissions/1',
        '/api/permissions/2',
        '/api/permissions/3',
        '/api/permissions/4',
        '/api/permissions/5',
        '/api/permissions/6'
      )
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'observer'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'actor'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/123', 'permission[role_title]' => 'publisher'
      ).and_return(created_permission)


      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/1234', 'permission[role_title]' => 'observer'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/1234', 'permission[role_title]' => 'publisher'
      ).and_return(created_permission)
      permissions.should_receive(:create).with(
        FlexMock.hsh 'permission[user_href]' => '/api/users/1234', 'permission[role_title]' => 'admin'
      ).and_return(created_permission)
      client.should_receive(:permissions).times(6).and_return(permissions)

      user_permissions = {
        '/api/users/123' => {'actor' => nil, 'publisher' => nil, 'observer' => nil},
        '/api/users/1234' => {'publisher' => nil, 'observer' => nil, 'admin' => nil}
      }
      created_permissions = RsUserPolicy::RightApi::PermissionUtilities.create_permissions(user_permissions, client)
      created_permissions.should == {
        '/api/users/123' => {
          'actor' => '/api/permissions/1',
          'publisher' => '/api/permissions/2',
          'observer' => '/api/permissions/3'
        },
        '/api/users/1234' => {
          'publisher' => '/api/permissions/4',
          'observer' => '/api/permissions/5',
          'admin' => '/api/permissions/6'
        }
      }
    end
  end
end