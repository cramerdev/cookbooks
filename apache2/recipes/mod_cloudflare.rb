#
# Cookbook Name:: apache2
# Recipe:: cloudflare
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

installed_module_path = '/usr/lib/apache2/modules/mod_cloudflare.so'

remote_file '/usr/src/mod_cloudflare.c' do
  source 'https://github.com/cloudflare/CloudFlare-Tools/raw/master/mod_cloudflare.c'
  owner 'root'
  group 'root'
  mode 0644
end

execute 'build cloudflare module' do
  user 'root'
  cwd '/usr/src'
  command 'apxs2 -a -i -c mod_cloudflare.c'
  creates installed_module_path
end

template "#{node[:apache][:dir]}/mods-available/cloudflare.load" do
  owner 'root'
  group 'root'
  mode 0644
  source 'mods/load.erb'
  variables :name => 'cloudflare', :path => installed_module_path
end

apache_module 'cloudflare'