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
    class MultiClient

      attr_accessor :accounts

      # Creates RightApi::Client instances for each account ID supplied.
      # If any supplied account ID is an enterprise master account, the
      # child accounts are found and added to this MultiClient as well.
      #
      # @param [String] email Email address of a RightScale user with permissions to access the API
      # @param [String] password Password of a RightScale user with permissions to access the API
      # @param [Array<Integer>] accounts List of accounts for which to create RightApi::Client objects
      def initialize(email, password, accounts)
        @accounts ||= {}
        accounts.each do |account_id|
          client = ::RightApi::Client.new(
            :email => email,
            :password => password,
            :account_id => account_id
          )
          this_account = {
            :client => client,
            :has_children => false
          }
          begin
            child_accounts = client.child_accounts.index
            this_account[:has_children] = true
            # NOTE: Assuming that children can not have grand children
            child_accounts.each do |child_account_res|
              # TODO: Looser coupling to the Utilities class here?
              child_account_id = RsUserPolicy::Utilities.id_from_href(child_account_res.href).to_i
              child_account = ::RightApi::Client.new(
                :email => email,
                :password => password,
                :account_id => child_account_id
              )
              @accounts[child_account_id] = {
                :client => child_account,
                :has_children => false,
                :parent => account_id
              }
            end
          rescue ::RightApi::ApiError => e
            raise e unless e.message =~ /enterprise/ || e.message =~ /Permission denied/
          end
          @accounts[account_id] = this_account
        end
      end

      def length
        @accounts.length
      end

      def size
        length
      end

      def [](account_id)
        @accounts[account_id]
      end

      def each(&block)
        @accounts.each do |account_id,account|
          yield account_id, account
        end
      end
    end
  end
end