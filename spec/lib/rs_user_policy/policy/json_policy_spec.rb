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

describe RsUserPolicy::Policy::JsonPolicy do
  context :initialize do
    it "Raises exception if no policy source is provided" do
      lambda { RsUserPolicy::Policy::JsonPolicy.new }.should raise_error ArgumentError
    end

    it "Doesn't freak out when bogus options are passed" do
      lambda { RsUserPolicy::Policy::JsonPolicy.new(:json => {}, :bogus_param => '') }.should_not raise_error
    end

    context :filename do
      it "Raises exception if the file does not exist" do
        lambda { RsUserPolicy::Policy::JsonPolicy.new(:filename => "foo") }.should raise_error Errno::ENOENT
      end

      it "Raises exception if input is not JSON" do
        filename = "/tmp/foo.json"
        File.open(filename, 'w') do |file|
          file.write('')
        end
        lambda { RsUserPolicy::Policy::JsonPolicy.new(:filename => filename) }.should raise_error JSON::ParserError
        File.delete(filename)
      end
    end

    context :json_str do
      it "Raises exception if input is not JSON" do
        lambda { RsUserPolicy::Policy::JsonPolicy.new(:json_str => '') }.should raise_error JSON::ParserError
      end
    end
  end

  context :get_permissions do
    it "Returns an empty array if a non existent role is requested" do
      policy = RsUserPolicy::Policy::JsonPolicy.new(:json => {})
      policy.get_permissions(['foo'], '/api/accounts/123').should == []
    end

    it "Returns an empty array if role does not have specific account or default" do
      policy = RsUserPolicy::Policy::JsonPolicy.new(:json => { "foo" => {} })
      policy.get_permissions(['foo'], '/api/accounts/123').should == []
    end

    it "Returns a default if specific account is not specified" do
      policy = RsUserPolicy::Policy::JsonPolicy.new(:json => { "foo" => {"default" => ["foo"]} })
      policy.get_permissions(['foo'], '/api/accounts/123').should == ["foo"]
    end

    it "Returns specific account (and not default) if specified" do
      policy = RsUserPolicy::Policy::JsonPolicy.new(:json => { "foo" => {"/api/accounts/123" => ["bar"], "default" => ["foo"]} })
      policy.get_permissions(['foo'], '/api/accounts/123').should == ["bar"]
    end

    it "Returns greatest permissions from many roles" do
      policy = RsUserPolicy::Policy::JsonPolicy.new(:json => {
        "foo" => {"/api/accounts/123" => ["bar"], "default" => ["foo"]},
        "bar" => {"default" => ["baz"]}
      })
      policy.get_permissions(['foo','bar'], '/api/accounts/123').should == ['bar','baz']
      policy.get_permissions(['foo','bar'], '/api/accounts/foo').should == ['foo','baz']
    end
  end
end