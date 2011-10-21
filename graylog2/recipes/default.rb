#
# Cookbook Name:: graylog2
# Recipe:: default
#
# Copyright 2010, Medidata Solutions Inc.
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

include_recipe 'java'

apt_repository 'mongodb' do
  keyserver 'keyserver.ubuntu.com'
  key '7F0CEB10'
  uri 'http://downloads.mongodb.org/distros/ubuntu'
  distribution '10.4'
  components ['10gen']
  action :add
end

apt_repository 'graylog2' do
  keyserver 'keyserver.ubuntu.com'
  key 'D77A4DCC'
  uri 'http://ppa.lunix.com.au/ubuntu/'
  distribution 'lucid'
  components ['main']
  action :add
end

package 'mongodb-stable'
package 'graylog2-server'

template '/etc/mongodb.conf' do
  source 'mongodb.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[mongodb]'
end

service 'mongodb' do
  action [:enable, :start]
end

template "/etc/graylog2.conf" do
  source "graylog2.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service 'graylog2-server' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

