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
  module UserAssignments
    module UserAssignments
      # Returns a list of all user emails which have a user assignment in the source
      #
      # @return [Array<String>] An array of email addresses for users with a user assignment
      def list
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # @return [Int] The number of users in the user assignments object
      def length
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # @return [Int] The number of users in the user assignments object
      def size
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # Returns the roles assigned to the user.  If the user does not exist
      # they should be automatically created with the role "immutable"
      #
      # @param [String] email The email address for the user
      #
      # @return [Array<String>] The roles assigned to the user
      def get_roles(email)
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # Deletes a user from the user assignments
      #
      # @param [String] email The email address for the user
      def delete(email)
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # Commits any changes made to the UserAssignments object back to
      # it's original data store.  This is an opportunity to perform
      # DB flushes or write back to a source file.
      #
      # @param [Hash] options A hash of values which may be required to serialize
      def serialize(options={})
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # Returns a hash which represents the user specified by the email address specified
      # If the user does not exist the (see #add_user) method will be called and the
      # user will be created.
      #
      # @param [String] email The email address of the user to fetch
      #
      # @return [Hash] A hash of key/value pairs to be passed to the RightScale API for Users#create.  This will also include a "roles" key, and may also include any other keys returned by the source
      def [](email)
        raise NotImplementedError, "Please implement this in your concrete class"
      end

      # Adds a user to user_assignments.  If the user already exists the existing record
      # will be returned.  Otherwise the user will be created with a single role of "immutable"
      #
      # @param [String] email The email address of the user to create or return
      # @param [Hash] options Hash of property key/value pairs for the user.  The following options are known, but there can be any key in thi hash
      # @option options [Array<String>] "roles" An array of role names for the user
      #
      # @return [Hash] The added or existing user where they key is the users email, and the value is a hash of key/value pairs of user properties.
      def add_user(email, options={})
        raise NotImplementedError, "Please implement this in your concrete class"
      end
    end
  end
end