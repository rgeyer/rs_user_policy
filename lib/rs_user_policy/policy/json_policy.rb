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

require File.expand_path(File.join(File.dirname(__FILE__), 'policy'))
require 'json'

module RsUserPolicy
  module Policy
    class JsonPolicy
      include Policy

      # Initializes a new Policy
      #
      # If more than one source is passed into options, the order of preference will be
      # [:json, :json_str, :filename]
      #
      # @param [Hash] options A hash of inputs for the new JSONPolicy
      # @option options [Hash] :json A hash containing the policy
      # @option options [String] :json_str A JSON string containing the policy
      # @option options [String] :filename Path and filename to a file containing the policy in JSON
      #
      # @raise [ArgumentError] If neither a filename or json object were supplied
      # @raise [Errno::ENOENT] If :filename was specified but the policy file does not exist
      # @raise [JSON::ParseError] If the policy is not valid JSON
      def initialize(options={})
        if ([:filename, :json, :json_str] & options.keys()).empty?
          raise ArgumentError, "You must supply either a filename, JSON string, or a JSON object"
        end

        if options.has_key?(:json)
          @policy = options[:json]
        elsif options.has_key?(:json_str)
          @policy = JSON.parse(options[:json_str])
        else
          @policy = JSON.parse(File.read(options[:filename]))
        end

        validate()
      end

      # Returns an array of permissions for a particular role in a particular RightScale account
      #
      # @param [Array<String>] roles An array of role names for which permissions should be fetched
      # @param [String] account_href A RightScale API 1.5 href for the RightScale account
      #
      # @return [Array<String>] A list of permissions for the role and account pair requested.  An empty array is returned if no policy exists for the requested pair
      def get_permissions(roles, account_href)
        permissions = []
        roles.each do |role|
          if @policy.has_key?(role)
            permissions = permissions + (@policy[role][account_href] || @policy[role]['default'] || [])
          end
        end
        permissions.uniq
      end

      private

      def validate()
        # TODO: Also validate that the policy file is in the correct form.
        # I.E. {
        #   "policy-name": {
        #     "account-href-or-default": ["list", "of", "permissions"]
        #   }
        #}
      end

    end
  end
end