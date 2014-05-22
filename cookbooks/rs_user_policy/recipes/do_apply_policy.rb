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

unix_timestamp = Time.now.to_i
policy_file = ::File.join(Chef::Config[:file_cache_path], "rs_user_policy.json")
user_assignment_file = `ls -t #{node["rs_user_policy"]["user_assignments_dir"]} | head -n1`.strip
audit_dir = node["rs_user_policy"]["audits_dir"]
acct_id_options = ""
logfile = ::File.join(node["rs_user_policy"]["log_dir"], "rs_user_policy-#{unix_timestamp}.log")

node["rs_user_policy"]["account_ids"].each do |acct_id|
  acct_id_options = "#{acct_id_options} -a #{acct_id}"
end

file policy_file do
  content node["rs_user_policy"]["policy"]
  backup false
  action :create
end

execute "Run rs_user_policy" do
  cwd node["rs_user_policy"]["user_assignments_dir"]
  command "rs_user_policy -r #{node["rs_user_policy"]["email"]} -s #{node["rs_user_policy"]["password"]}#{acct_id_options} -p #{policy_file} -u #{user_assignment_file} -d #{audit_dir} -m > #{logfile} 2>&1"
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
