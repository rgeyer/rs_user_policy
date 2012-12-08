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

require File.expand_path(File.join(File.dirname(__FILE__), 'user_assignments'))
require 'json'

module RsUserPolicy
  module UserAssignments
    class JsonUserAssignments
      include UserAssignments

      # Initializes a new UserAssignments
      #
      # If more than one source is passed into options, the order of preference will be
      # [:json, :json_str, :filename]
      #
      # @param [Hash] options A hash of inputs for the new JsonUserAssignments, where the keys are;
      #   :json [Hash] A hash containing the user assignments
      #   :json_str [String] A JSON string containing the user assignments
      #   :filename [String] Path and filename to a file containing the user assignments in JSON
      #
      # @raise [Errno::ENOENT] If :filename was specified but the policy file does not exist
      # @raise [JSON::ParserError] If the policy is not valid JSON
      def initialize(options={})
        begin
          if options.has_key?(:json)
            @user_assignments = options[:json]
          elsif options.has_key?(:json_str)
            @user_assignments = JSON.parse(options[:json_str])
          elsif options.has_key?(:filename)
            @user_assignments = JSON.parse(File.read(options[:filename]))
          else
            @user_assignments = {}
          end
        rescue Errno::ENOENT, JSON::ParserError
          @user_assignments = {}
        end

        validate()
      end

      # @return [Int] The number of users in the user assignments object
      def length
        @user_assignments.length
      end

      # @return [Int] The number of users in the user assignments object
      def size
        self.length
      end

      # Returns the role assigned to the user.  If the user does not exist
      # they should be automatically created with the role "immutable"
      #
      # @param [String] email The email address for the user
      #
      # @return [String] The role assigned to the user
      def get_role(email)
        # TODO: This seems expensive to do in an accessor?
        unless @user_assignments.key?(email)
          @user_assignments[email] = 'immutable'
        end
        @user_assignments[email]
      end

      # Deletes a user from the user assignments
      #
      # @param [String] email The email address for the user
      def delete(email)
        @user_assignments.delete(email)
      end

      # Commits any changes made to the UserAssignments object back to
      # it's original data store.  This is an opportunity to perform
      # DB flushes or write back to a source file.
      #
      # @param [Hash] options A hash containing only one key;
      #   :filename [String] The filename to write out the JSON state of this JsonUserAssignments object
      #
      # @raise [ArgumentError] When no output file is specified
      def serialize(options={})
        raise ArgumentError, "You must specify the :filename option" unless options.has_key?(:filename)
        File.open(options[:filename], 'w') {|f| f.write(JSON.pretty_generate(@user_assignments))}
      end

      private

      def validate()
        # TODO: Also validate that the user assignments file is in the correct form.
        # I.E. {
        #   "email@address.com": "role"
        #}
      end
    end
  end
end