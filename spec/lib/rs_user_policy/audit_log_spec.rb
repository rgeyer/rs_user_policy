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

describe RsUserPolicy::AuditLog do
  context :initialize do
    it 'adds dryrun to audit log name when dryrun is specified' do
      audit_log = RsUserPolicy::AuditLog.new(:dry_run => true)
      audit_log.filename.should include '_dryrun'
    end

    it 'uses provided timestamp in filename' do
      ts = Time.now.to_i
      audit_log = RsUserPolicy::AuditLog.new(:timestamp => ts)
      audit_log.filename.should include "#{ts}"
    end

    it 'uses provided audit directory' do
      ts = Time.now.to_i
      audit_log = RsUserPolicy::AuditLog.new(:audit_dir => '/foo/bar/baz')
      audit_log.filename.should eq "/foo/bar/baz/audit_log-#{ts}.json"
    end

    it 'uses provided audit directory and handles trailing slash' do
      ts = Time.now.to_i
      audit_log = RsUserPolicy::AuditLog.new(:audit_dir => '/foo/bar/baz/')
      audit_log.filename.should eq "/foo/bar/baz/audit_log-#{ts}.json"
    end
  end

  context :add_entry do
    it 'can initialize entries for a user' do
      audit_log = RsUserPolicy::AuditLog.new
      audit_log.audit_log.should == {}
      audit_log.add_entry('ryan.geyer@rightscale.com', 'Acct1', 'deleted', 'deleted')
      audit_log.audit_log.keys.should include 'ryan.geyer@rightscale.com'
      audit_log.audit_log['ryan.geyer@rightscale.com'].length.should == 1
    end

    it 'combines entries for a single user' do
      audit_log = RsUserPolicy::AuditLog.new
      audit_log.audit_log.should == {}
      audit_log.add_entry('ryan.geyer@rightscale.com', 'Acct1', 'deleted', 'deleted')
      audit_log.add_entry('ryan.geyer@rightscale.com', 'Acct2', 'deleted', 'deleted')
      audit_log.audit_log.keys.should include 'ryan.geyer@rightscale.com'
      audit_log.audit_log['ryan.geyer@rightscale.com'].length.should == 2
    end
  end
end
