#
# Cookbook Name:: rs_user_policy
# Recipe:: do_update_user
#
# Copyright 2013, Ryan J. Geyer
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

user_assignment_file = ::File.join(node["rs_user_policy"]["user_assignments_dir"], `ls -t #{node["rs_user_policy"]["user_assignments_dir"]} | head -n1`.strip)

ruby_block "Set user role in latest user_assignments file (#{user_assignment_file})" do
  block do
    json = JSON.parse(::File.read(user_assignment_file))
    json[node["rs_user_policy"]["user"]["email"]] = {
      "roles" => node["rs_user_policy"]["user"]["roles"]
    }

    ::File.open(user_assignment_file, "w") do |file|
      file.write(JSON.pretty_generate(json))
    end
  end
end

remote_recipe "Request do_appy_policy" do
  recipe "rs_user_policy::do_apply_policy"
  recipients_tags "server:uuid=#{node["rightscale"]["instance_uuid"]}"
end

rightscale_marker :end