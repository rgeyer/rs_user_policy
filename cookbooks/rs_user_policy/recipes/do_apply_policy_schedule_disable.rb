#
# Cookbook Name:: rs_user_policy
# Recipe:: do_apply_policy_schedule_disable
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

cron "RightScale remote_recipe rs_user_policy::do_apply_policy" do
  user "root"
  action :delete
end

rightscale_marker :end