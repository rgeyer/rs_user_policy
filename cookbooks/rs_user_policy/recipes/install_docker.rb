#
# Cookbook Name:: rs_user_policy
# Recipe:: install
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

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

execute "Pull rgeyer/rs_user_policy container" do
  command "docker pull rgeyer/rs_user_policy:#{node['rs_user_policy']['docker']['container_version']}"
end
