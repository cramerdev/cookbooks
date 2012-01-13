#
# Cookbook Name:: postgresql
# Recipe:: pgpool
#
# Author:: Nathan L Smith (<nathan@cramerdev.com>)
# Copyright 2012, Cramer Development, Inc.
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

tar_package "http://www.pgpool.net/mediawiki/images/pgpool-II-#{node['postgresql']['pgpool']['version']}.tar.gz" do
  prefix '/usr/local'
  creates '/usr/local/bin/pgpool'
end

user 'postgres'

directory '/var/run/pgpool' do
  owner 'postgres'
  group 'postgres'
  mode '2775'
  action :create
end

template '/etc/init.d/pgpool2' do
  source 'pgpool2.init.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'pgpool2' do
  supports [:start, :stop, :restart, 'try-restart', :reload, 'force-reload']
end

template '/usr/local/etc/pgpool.conf' do
  source 'pgpool.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  notifies :restart, 'service[pgpool2]'
end

template '/usr/local/etc/pcp.conf' do
  source 'pcp.conf.erb'
  owner 'postgres'
  group 'postgres'
  mode '0644'
  notifies :restart, 'service[pgpool2]'
end

