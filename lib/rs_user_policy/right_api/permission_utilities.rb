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
  module RightApi
    # A set of utility methods for manipulating permissions using the RightScale right_api_client gem
    #
    # Allows bulk actions on permissions without worrying about the complexity of retrying,
    # creating/deleting in the correct order, and the like.
    #
    class PermissionUtilities

      @@permission_delete_order = [
        'enterprise_manager',
        'admin',
        'security_manager',
        'actor',
        'billing',
        'server_superuser',
        'server_login',
        'publisher',
        'designer',
        'library',
        'lite_user',
        'observer'
      ]

      # Destroys all passed in permissions with the specified client.
      # This method handles deleting permissions in the appropriate order to avoid the dreaded;
      # RightApi::ApiError: Error: HTTP Code: 422, Response body: A user must have the observer role.
      # TODO: Handle a 422 resulting from calling delete too quickly and attempting to remove "observer" when other deletes have not been committed
      #
      # @param [Array<RightApi::ResourceDetail>] permissions
      #   A hash of permissions where the key is the RightScale API href, and the
      #   value is the role_title.  These permissions can be for one or many users, allowing a bulk actions.
      # @param [RightApi::Client] client
      #   An active RightApi::Client instance for the account referenced in account_href
      #
      # @raise [RightApi::ApiError] If an unrecoverable API error has occurred.
      #
      # @return [Hash] A hash where the keys are the permission hrefs destroyed, and the values are the role_title of those permissions
      def self.destroy_permissions(permissions, client)
        perms_hash = {}
        permissions.each{|p| perms_hash[p.href] = p.role_title }
        RsUserPolicy::Utilities.yield_on_values_in_order(@@permission_delete_order, perms_hash) do |perm_href,role_title|
          client.permissions(:id => RsUserPolicy::Utilities.id_from_href(perm_href)).destroy()
        end
        perms_hash
      end

      # Creates all the passed in permissions using the supplied client.
      # This method handles creating permissions with "observer" first in order to avoide the dreaded;
      # RightApi::ApiError: Error: HTTP Code: 422, Response body: A user must have the observer role.
      #
      # @param [Hash] permissions
      #   A hash where the key is a RightScale API User href, and the value is a hash where the key is the permission role_title that the user should be granted, and the value is nil.
      #
      # @param [RightApi::Client] client
      #   An active RightApi::Client instance for the account referenced in account_href
      #
      # @raise [RightApi::ApiError] If an unrecoverable API error has occurred.
      #
      # @return [Hash] The permissions input hash, where the nil values have been replaced with the href of the permission which was created.
      #
      # @example Create "observer" and "admin" permissions for two users
      #   client = RightApi::Client.new(</snip>)
      #
      #   permissions = {
      #     '/api/users/123' => {
      #       'observer' => nil,
      #       'admin' => nil
      #     },
      #     '/api/users/456' => {
      #       'observer' => nil,
      #       'admin' => nil
      #     }
      #   }
      #
      #   response = RsUserPolicy::RightApi::PermissionUtilities.create_permissions(permissions, client)
      #
      #   puts JSON.pretty_generate(response)
      #
      #   # Output would be as follows
      #   {
      #     '/api/users/123' => {
      #       'observer' => '/api/permissions/1',
      #       'admin' => '/api/permissions/2'
      #     },
      #     '/api/users/456' => {
      #       'observer' => '/api/permissions/3',
      #       'admin' => '/api/permissions/4'
      #     }
      #   }
      def self.create_permissions(permissions, client)
        permissions.each do |user_href,perm_ary|
          user_perms_hash = Hash[perm_ary.keys.map{|p| [p, user_href]}]
          RsUserPolicy::Utilities.yield_on_keys_in_order(['observer'], user_perms_hash) do |role_title,user_href|
            created_permission = client.permissions.create(
              {
                'permission[user_href]' => user_href,
                'permission[role_title]' => role_title
              }
            )
            permissions[user_href][role_title] = created_permission.href
          end
        end
        permissions
      end

    end
  end
end
