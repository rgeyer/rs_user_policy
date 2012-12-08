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

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'helper'))

describe RsUserPolicy::UserAssignments::JsonUserAssignments do
  context :length_and_size do
    it "Returns the number of user assigment records" do
      user_assignments = RsUserPolicy::UserAssignments::JsonUserAssignments.new(:json => {"one" => "one", "two" => "two"})
      user_assignments.length.should == 2
      user_assignments.size.should == 2
    end
  end

  context :get_role do
    it "Adds a user as immutable if the user does not already exist" do
      user_assignments = RsUserPolicy::UserAssignments::JsonUserAssignments.new()
      user_assignments.length.should == 0
      user_assignments.get_role("email@foo.bar").should == "immutable"
      user_assignments.length.should == 1

      # Make sure the user gets added only once
      user_assignments.get_role("email@foo.bar").should == "immutable"
      user_assignments.length.should == 1
    end
  end

  context :delete do
    it "Removes a user from the user assignments" do
      user_assignments = RsUserPolicy::UserAssignments::JsonUserAssignments.new(:json => {"one" => "one", "two" => "two"})
      user_assignments.length.should == 2
      user_assignments.delete("one")
      user_assignments.length.should == 1
    end
  end

  context :serialize do
    it "Raises an exception if no filename is specified" do
      user_assignments = RsUserPolicy::UserAssignments::JsonUserAssignments.new()
      lambda { user_assignments.serialize() }.should raise_error ArgumentError
    end

    it "Writes a JSON file to the specified location" do
      filename = "/tmp/user_assignments_test#{Time.now.to_i}.json"
      user_assignments = RsUserPolicy::UserAssignments::JsonUserAssignments.new()
      user_assignments.serialize(:filename => filename)
      File.exists?(filename).should == true
      JSON.parse(File.read(filename)).should == {}
      File.delete(filename)
    end
  end
end