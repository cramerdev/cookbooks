#
# Cookbook Name:: haproxy
# Recipe:: source
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

# Install haproxy 1.4 from source

version = node['haproxy']['source']['version']

remote_file "/usr/src/haproxy-#{version}.tar.gz" do
  source "http://haproxy.1wt.eu/download/1.4/src/haproxy-#{version}.tar.gz"
end

execute 'extract source' do
  command "tar xfz haproxy-#{version}.tar.gz"
  cwd '/usr/src'
  creates "haproxy-#{version}"
end

execute 'compile and install' do
  command 'make && make install'
  environment({ 'TARGET'  => 'linux26',
                'DESTDIR' => node['haproxy']['source']['prefix'] })
  cwd "/usr/src/haproxy-#{version}"
  creates '/usr/local/sbin/haproxy'
end

template '/etc/haproxy.conf' do
  source 'haproxy.cfg.erb'
  owner 'root'
  group 'root'
  # For internal use, these are not exactly how a normal person would use them
  mode '0666'
  action :create_if_missing
end

template '/etc/init.d/haproxy' do
  source 'haproxy.init.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'haproxy' do
  supports :restart => true, :status => true, :reload => true
  action :enable
end
