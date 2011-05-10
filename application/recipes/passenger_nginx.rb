#
# Cookbook Name:: application
# Recipe:: passenger_nginx
#
# Copyright 2009, Opscode, Inc.
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

app = node.run_state[:current_app]

include_recipe 'nginx::passenger'

template "#{node[:nginx][:dir]}/sites-available/#{app[:id]}.conf" do
  source 'web_app.conf.erb'
  cookbook app[:cookbook] || app[:id]
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :app => app,
    :docroot => "#{app[:deploy_to]}/current/public",
    :server_name => (app[:domain_name] || {})[node[:app_environment]] ||
      "#{app[:id]}.#{node[:domain]}",
    :server_aliases => [ node[:fqdn], app[:id] ],
    :rails_env => node[:app_environment],
    :ssl => (app[:ssl] || {})[node[:app_environment]] || {},
    :auth => (app[:auth] || {})[node[:app_environment]] || {}
  )
  notifies :restart, 'supervisor_service[nginx]'
end

nginx_site "#{app['id']}.conf" do
  notifies :restart, 'supervisor_service[nginx]'
end

d = resources(:deploy_revision => app[:id])
d.restart_command do
  execute 'restart passenger' do
    user app[:owner]
    command "touch #{app[:deploy_to]}/current/tmp/restart.txt"
  end
end

