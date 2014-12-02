# Copyright (c) 2012-2013 Ryan J. Geyer
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
  class User
    attr_reader :email, :href, :permissions, :user

    # Initializes read only attributes for an RsUserPolicy::User
    #
    # @param [RightApi::ResourceDetail] user The user detail returned by RightApi::Client
    def initialize(user)
      @email = user.email
      @href = user.href
      @user = user
      @permissions = {}
    end

    # Converts this object to a hash which can be serialized
    def to_hash()
      rethash = {
        "permissions" => @permissions
      }
      (@user.attributes - [:links]).each do |attr_sym|
        rethash[attr_sym.to_s] = @user.send(attr_sym.to_s)
      end
      rethash
    end

    # Adds a single permission for a single RightScale account
    #
    # @param [String] account_href The RightScale API href of the account
    # @param [RightApi::ResourceDetail] permission A single RightApi::ResourceDetail for a permission.
    def add_permission(account_href, permission)
      @permissions[account_href] ||= []
      @permissions[account_href] << permission
    end

    # Returns the RightScale permissions the user has for the specified account href
    #
    # @param [String] account_href The RightScale API href of the account
    #
    # @return [Array<RightApi::ResourceDetail>] An array of permission RightApi::ResourceDetail objects
    def get_api_permissions(account_href)
      @permissions[account_href] || []
    end

    # Removes all permissions for the user in the specified rightscale account using the supplied client
    #
    # @param [String] account_href The RightScale API href of the account
    # @param [RightApi::Client] client An active RightApi::Client instance for the account referenced in account_href
    # @param [Hash] options Optional parameters
    # @option options [Bool] :dry_run If true, no API calls will be made, but the return value will contain the actions which would have been taken
    #
    # @raise [RightApi::ApiError] If an unrecoverable API error has occurred.
    #
    # @return [Hash] A hash where the keys are the permission hrefs destroyed, and the keys are the role_title of those permissions
    def clear_permissions(account_href, client, options={})
      options = {:dry_run => false}.merge(options)
      current_permissions = get_api_permissions(account_href)
      if options[:dry_run]
        Hash[current_permissions.map{|p| [p.href, p.role_title]}]
      else
        retval = RsUserPolicy::RightApi::PermissionUtilities.destroy_permissions(
          current_permissions,
          client
        )
        @permissions.delete(account_href)
        retval
      end
    end

    # Removes and adds permissions as appropriate so that the users current permissions reflect
    # the desired set passed in as "permissions"
    #
    # @param [Array<String>] permissions The list of desired permissions for the user in the specified account
    # @param [String] account_href The RightScale API href of the account
    # @param [RightApi::Client] client An active RightApi::Client instance for the account referenced in account_href
    # @param [Hash] options Optional parameters
    # @option options [Bool] :dry_run If true, no API calls will be made, but the return value will contain the actions which would have been taken
    #
    # @raise [RightApi::ApiError] If an unrecoverable API error has occurred.
    #
    # @return [Hash,Hash] A tuple where two hashes are returned.  The keys of the hashes are the href of the permission, and the values are the role_title of the permission.  The first hash is the permissions removed, and the second hash is the permissions added
    def set_api_permissions(permissions, account_href, client, options={})
      options = {:dry_run => false}.merge(options)
      existing_api_permissions_response = get_api_permissions(account_href)
      existing_api_permissions = Hash[existing_api_permissions_response.map{|p| [p.role_title, p] }]
      if permissions.length == 0
        removed = clear_permissions(account_href, client, options)
        @permissions.delete(account_href)
        return removed, {}
      else
        permissions_to_remove = (existing_api_permissions.keys - permissions).map{|p| existing_api_permissions[p]}
        remove_response = Hash[permissions_to_remove.map{|p| [p.href, p.role_title]}]
        unless options[:dry_run]
          remove_response = RsUserPolicy::RightApi::PermissionUtilities.destroy_permissions(permissions_to_remove, client)
        end

        permissions_to_add = {
          @href => Hash[(permissions - existing_api_permissions.keys).map{|p| [p,nil]}]
        }
        add_response = {}
        if options[:dry_run]
          href_idx = 0
          add_response = {
            @href => Hash[(permissions - existing_api_permissions.keys).map{|p| [p,(href_idx += 1)]}]
          }
        else
          add_response = RsUserPolicy::RightApi::PermissionUtilities.create_permissions(permissions_to_add, client)
        end

        @permissions[account_href] = client.permissions.index(:filter => ["user_href==#{@href}"]) unless options[:dry_run]

        return remove_response, Hash[add_response[@href].keys.map{|p| [add_response[@href][p],p]}]
      end
    end
  end
end
