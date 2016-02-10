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

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))
require 'json'

rs_user_policy_binfile = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "bin", "rs_user_policy"))

describe "RS User Policy Bin" do

  context :valid_policy_json do
    it "Exits with exception when policy file does not exist" do
      output = `#{rs_user_policy_binfile} --rs-email="foo" --rs-pass="bar" --rs-acct-num="baz" --policy="foobarbaz.txt"`
      output.should include "Unable to initialize policy from filename foobarbaz.txt.  Error: No such file or directory"
      $?.exitstatus.should == 1
    end

    it "Exits with exception when policy file is not valid json" do
      tmpfile = File.join("/tmp", "policy.json")
      File.open(tmpfile, 'w') do |file|
        file.write "This is not a valid json file, not at all..."
      end
      output = `#{rs_user_policy_binfile} --rs-email="foo" --rs-pass="bar" --rs-acct-num="baz" --policy="#{tmpfile}"`
      File.delete(tmpfile)
      output.should include "Unable to initialize policy from filename #{tmpfile}.  Error: 757: unexpected token at"
      $?.exitstatus.should == 1
    end
  end

  context :user_assignment_json do
    context "missing_user_assignments_fatal is true" do
      it "Exits with exception when user_assigments is not provided" do
        tmp_policy = File.join("/tmp", "policy.json")
        File.open(tmp_policy, 'w') do |file|
          file.write "{}"
        end

        output = `#{rs_user_policy_binfile} --rs-email="foo" --rs-pass="bar" --rs-acct-num="baz" --policy="#{tmp_policy}" --empty-user-assignments-fatal`
        File.delete(tmp_policy)
        output.should include "There were 0 user_assigments from filename .  Exitting due to empty_user_assigments_fatal being set."
        $?.exitstatus.should == 1
      end

      it "Exits with exception when user_assigments is empty" do
        tmp_policy = File.join("/tmp", "policy.json")
        File.open(tmp_policy, 'w') do |file|
          file.write "{}"
        end

        tmp_ua = File.join("/tmp", "ua.json")
        File.open(tmp_ua, "w") do |file|
          file.write "{}"
        end

        output = `#{rs_user_policy_binfile} --rs-email="foo" --rs-pass="bar" --rs-acct-num="baz" --policy="#{tmp_policy}" --user-assignments="#{tmp_ua}" --empty-user-assignments-fatal`
        File.delete(tmp_policy)
        File.delete(tmp_ua)
        output.should include "There were 0 user_assigments from filename .  Exitting due to empty_user_assigments_fatal being set."
        $?.exitstatus.should == 1
      end
    end
  end

end
