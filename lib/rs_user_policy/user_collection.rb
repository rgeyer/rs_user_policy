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
  class UserCollection

    def initialize
      @users_by_href = {}
    end

    # TODO: An .each iterator.. instead of a .users accessor

    # @return [Array<RsUserPolicy::User>] An array of RsUserPolicy::User added to the collection
    def users
      @users_by_href.values
    end

    # Adds users to this collection only if the collection does not already
    # include the specified users.  The users RightScale API href is used
    # as the unique identifier for deduplication
    #
    # @param [Array<RightApi::ResourceDetail>] An array of ResourceDetail from the Right API Client for users.  Returned by client.users.index
    def add_users(users)
      users.each do |user|
        unless @users_by_href.has_key?(user.href)
          @users_by_href[user.href] = RsUserPolicy::User.new(user.email, user.href)
        end
      end
    end

    def [](idx)
      @users_by_href[idx]
    end

    def add_permissions(account_href, permissions)
      permissions.each do |permission|
        user_href = permission.user.href
        add_users([permission.user])
        @users_by_href[user_href].add_permission(account_href, permission)
      end
    end
  end
end