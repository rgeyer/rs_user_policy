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
  class AuditLog

    attr_accessor :filename, :audit_log

    # Initializes a new AuditLog
    #
    # @param [Hash] options A hash of options that impact the audit log filename.  Possible options are;
    #   :timestamp [String] The timestamp to append to the filename
    #   :dry_run [Bool] A boolean indicating if this is a dry run
    def initialize(options={})
      timestamp = options[:timestamp] || Time.now.to_i
      @audit_log = {}
      @filename = "audit_log#{options[:dry_run] ? '_dryrun' : ''}-#{timestamp}.json"
    end

    # Adds a new entry to the audit log
    #
    # @param [String] email The email address of the user impacted by the change
    # @param [String] account The account name impacted by the change
    # @param [String] action The action performed.  Expected options are ['update_permissions', 'deleted']
    # @param [String] changes A free form description of the changes
    def add_entry(email, account, action, changes)
      @audit_log[email] = [] unless audit_log[email]
      @audit_log[email] << {
        :account => account,
        :action => action,
        :changes => changes
      }
    end

    # Writes the audit log to a file
    #
    def write_file
      File.open(@filename, 'w') {|f| f.write(JSON.pretty_generate(@audit_log))}
    end
  end
end