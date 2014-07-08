#
# Cookbook Name:: rs_user_policy
# Recipe:: install_gem
#
# Copyright 2014, Ryan J. Geyer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rightscale_marker :begin

ruby_block "Install rs_user_policy to the system direct from rubygems.org" do
  block do
    `/usr/bin/gem install rs_user_policy --no-ri --no-rdoc --source http://rubygems.org`
  end
end

directory node["rs_user_policy"]["home"] do
  recursive true
end

directory node["rs_user_policy"]["user_assignments_dir"] do
  recursive true
end

directory node["rs_user_policy"]["audits_dir"] do
  recursive true
end

directory node["rs_user_policy"]["log_dir"] do
  recursive true
end

ruby_block "Create the initial user_assignment file if (#{node["rs_user_policy"]["user_assignments_dir"]}) is empty" do
  block do
    if Dir["#{node["rs_user_policy"]["user_assignments_dir"]}/*"].empty?
      ::File.open(::File.join(node["rs_user_policy"]["user_assignments_dir"], "user_assignments.json"), "w") do |file|
        file.write(node["rs_user_policy"]["user_assignments"]["json"])
      end
    end
  end
end

rightscale_marker :end
