#
# Cookbook Name:: application
# Recipe:: apache2_proxied
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

app = node.run_state[:current_app]

include_recipe "apache2"

# First, install any application specific packages
if app[:packages]
  app[:packages].each do |pkg,ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

# Next, install any application specific gems
if app[:gems]
  app[:gems].each do |gem,ver|
    gem_package gem do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

template "#{node[:apache][:dir]}/sites-available/#{app[:id]}.conf" do
  source 'apache2_proxied.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables :app => app
  notifies :restart, 'service[apache2]'
end

apache_site "#{app[:id]}.conf" do
  notifies :restart, 'service[apache2]'
end

