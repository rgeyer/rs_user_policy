#
# Cookbook Name:: rs_user_policy
# Recipe:: do_apply_policy
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

policy_file = ::File.join(node['rs_user_policy']['home'], "rs_user_policy.json")

case node['rs_user_policy']['runtime_environment']
when 'gem'
  unix_timestamp = Time.now.to_i
  user_assignment_file = `ls -t #{node["rs_user_policy"]["user_assignments_dir"]} | head -n1`.strip
  audit_dir = node["rs_user_policy"]["audits_dir"]
  acct_id_options = ""
  logfile = ::File.join(node["rs_user_policy"]["log_dir"], "rs_user_policy-#{unix_timestamp}.log")

  node["rs_user_policy"]["account_ids"].each do |acct_id|
    acct_id_options = "#{acct_id_options} -a #{acct_id}"
  end

  rs_user_policy_command = "rs_user_policy -r #{node["rs_user_policy"]["email"]} -s #{node["rs_user_policy"]["password"]}#{acct_id_options} -p #{policy_file} -u #{user_assignment_file} -d #{audit_dir} -e > #{logfile} 2>&1"
when 'docker'
  rs_user_policy_command = "docker run -v #{node['rs_user_policy']['home']}:/opt/rs_user_policy -e POLICY=/opt/rs_user_policy/rs_user_policy.json -e EMAIL=#{node['rs_user_policy']['email']} -e PASSWORD=#{node['rs_user_policy']['password']} -e ACCOUNT_IDS=#{node['rs_user_policy']['account_ids'].join(",")} -e USER_ASSIGNMENTS=latest rgeyer/rs_user_policy:#{node['rs_user_policy']['docker']['container_version']}"
else
  raise "#{node['rs_user_policy']['runtime_environment']} is not a supported runtime environment.  Try either 'gem' or 'docker'."
end

file policy_file do
  content node["rs_user_policy"]["policy"]
  backup false
  action :create
end

execute "Run rs_user_policy" do
  cwd node["rs_user_policy"]["user_assignments_dir"]
  command rs_user_policy_command
end

file policy_file do
  action :delete
end

bash "Clean up old user_management*.json and log files" do
  code <<-EOF
for i in `find #{node["rs_user_policy"]["audits_dir"]} -type f -mtime #{node["rs_user_policy"]["retention_period"]}`
do
  rm $i
done

for i in `find #{node["rs_user_policy"]["user_assignments_dir"]} -type f -mtime #{node["rs_user_policy"]["retention_period"]}`
do
  rm $i
done

for i in `find #{node["rs_user_policy"]["log_dir"]} -type f -mtime #{node["rs_user_policy"]["retention_period"]}`
do
  rm $i
done
  EOF
end

rightscale_marker :end
