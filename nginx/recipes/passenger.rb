#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009-2011, Opscode, Inc.
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

include_recipe 'build-essential'
include_recipe 'supervisor'

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev', 'libcurl4-openssl-dev']
  )

packages.each do |devpkg|
  package devpkg
end

gem_package 'passenger'

nginx_version = node[:nginx][:version]

node.set[:nginx][:install_path]    = "/opt/nginx-#{nginx_version}"
node.set[:nginx][:src_binary]      = "#{node[:nginx][:install_path]}/sbin/nginx"
node.set[:nginx][:daemon_disable]  = true
node.set[:nginx][:configure_flags] = [
  "--prefix=#{node[:nginx][:install_path]}",
  "--conf-path=#{node[:nginx][:dir]}/nginx.conf",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module"
]

configure_flags = node[:nginx][:configure_flags].join(" ")

bash "compile_nginx_source" do
  code <<-EOH
    passenger-install-nginx-module --auto --prefix=#{node[:nginx][:install_path]} --auto-download --extra-configure-flags='#{configure_flags}'
  EOH
  creates node[:nginx][:src_binary]
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

# Rotate logs
template '/etc/logrotate.d/nginx' do
  source 'logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

directory '/var/www/nginx-default' do
  owner "root"
  group "root"
  mode '0755'
  recursive true
end

cookbook_file '/var/www/nginx-default/index.html' do
  backup false
  owner 'root'
  group 'root'
  mode '0644'
end

service 'nginx' do
  provider 'supervisor_service'
  start_command "#{node[:nginx][:src_binary]} -c #{node[:nginx][:dir]}/nginx.conf"
  subscribes :restart, resources('bash[compile_nginx_source]')
end

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
  end
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner 'root'
  group 'root'
  mode '0644'
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources('service[nginx]'), :immediately
end

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode '0644'
  notifies :restart, resources('service[nginx]'), :immediately
end

template "#{node[:nginx][:dir]}/conf.d/passenger.conf" do
  source 'passenger.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, resources('service[nginx]')
end

nginx_site 'default' do
  notifies :restart, resources('service[nginx]')
end
