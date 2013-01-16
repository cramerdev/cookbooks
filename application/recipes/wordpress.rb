#
# Cookbook Name:: application
# Recipe:: wordpress
#
# Copyright 2010, Cramer Development, Inc.
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

app = node.run_state[:current_app]

include_recipe "apache2"

app['owner'] ||= app['user']
app['group'] ||= app['user']

directory app['deploy_to'] do
  owner node[:apache][:user]
  group node[:apache][:user]
  mode "0755"
  action :create
end

# This is another kind of a hack to deal with the transition between deploy
# strategies for one project.
unless app['skip_wp']
  remote_file "#{Chef::Config[:file_cache_path]}/wordpress.tar.gz" do
    source 'http://wordpress.org/latest.tar.gz'
    mode '0644'
    action :create_if_missing
  end
  execute 'extract wordpress' do
    command "tar xfz #{Chef::Config[:file_cache_path]}/wordpress.tar.gz -C #{app['deploy_to']} --strip=1 wordpress/*"
    user node['apache']['user']
    creates "#{app['deploy_to']}/wp-app.php"
  end

  ['', 'plugins', 'themes'].each do |dir|
    directory "#{app['deploy_to']}/wp-content/#{dir}" do
      owner node['apache']['user']
      group node['apache']['group']
      mode '0755'
    end
  end

  file "#{app['deploy_to']}/.htaccess" do
      owner node['apache']['user']
      group node['apache']['group']
      mode '0644'
      action :create_if_missing
  end
end

# Set the config directory based on the "deploy_with" directive
#
# This is kind of a hack to deal with the transition between deploy strategies
# for one project.
config_path = app['deploy_with'] == 'cap' ? "#{app['deploy_to']}/shared/config" :
  app['deploy_to']

db = (app['databases'] || {})[node.chef_environment] || {}
db['host'] ||= 'localhost'

unless app[:skip_config]
  template "wp-config.php" do
    path "#{config_path}/wp-config.php"
    variables(
      :db   => db,
      :keys => app['wordpress']['keys'],
      :url  => "http://" + app['domain_name'][node.chef_environment]
    )
    owner node['apache']['user']
    group node['apache']['group']
    mode '0600'
  end
end

# Allow the app to be the default site
app_conf = app[:default_site] ? "0000-#{app[:id]}" : app[:id]

web_app app_conf do
  docroot app['docroot'] || app['deploy_to']
  template "web_app.conf.erb"
  cookbook app['cookbook'] || app['id']
  user app['owner']
  ssl app[:ssl] || {}
  server_name app['domain_name'][(node.chef_environment || 'production')]
  log_dir node[:apache][:log_dir]
end

