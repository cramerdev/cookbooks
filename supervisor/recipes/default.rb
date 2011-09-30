#
# Cookbook Name:: supervisor
# Recipe:: default
#
# Copyright 2011, Cramer Development, Inc.
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
#

package 'supervisor'

# Add nagios/icinga users to supervisor group
more_users = []
%w{ icinga nagios }.each do |service|
  if node[service] && node[service]['user']
    more_users << node[service]['user']
  end
end

group node['supervisor']['group'] do
  members more_users
  append true
end

service 'supervisor' do
  ignore_failure true
  action [:enable, :start]
end

template '/etc/supervisor/supervisord.conf' do
  source 'supervisord.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[supervisor]'
end

