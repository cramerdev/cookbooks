#
# Cookbook Name:: application
# Recipe:: nanoc3_nginx
#
# Copyright 2011, Cramer Development, Inc.
#
# All rights reserved.
#

%w{ nanoc3 RedCloth coderay kramdown }.each do |gem|
  gem_package gem
end

app = node.run_state[:current_app]

## First, install any application specific packages
if app[:packages]
  app[:packages].each do |pkg,ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

## Next, install any application specific gems
if app[:gems]
  app[:gems].each do |gem,ver|
    gem_package gem do
      action :install
      version ver if ver && ver.length > 0
    end
  end
end

template "#{node[:nginx][:dir]}/sites-available/#{app[:id]}.conf" do
  source 'nanoc3_nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :app => app[:id],
    :docroot => "#{app[:deploy_to]}/current/deploy",
    :server_name => (app[:domain_name] || {})[node[:app_environment]] ||
      "#{app[:id]}.#{node[:domain]}",
    :server_aliases => [ node[:fqdn], app[:id] ],
    :domain_aliases => (app[:domain_aliases] || {})[node[:app_environment]] || []
  )
  notifies :restart, resources('supervisor_service[nginx]')
end

nginx_site "#{app[:id]}.conf"

directory app[:deploy_to] do
  owner app[:owner]
  group app[:group]
  mode 0755
  recursive true
end

directory "#{app[:deploy_to]}/shared" do
  owner app[:owner]
  group app[:group]
  mode 0755
  recursive true
end

directory "#{app[:deploy_to]}/shared/output" do
  owner app[:owner]
  group app[:group]
  mode 0755
  recursive true
end

if app.has_key?('deploy_key')
  ruby_block 'write_key' do
    block do
      f = File.open("#{app[:deploy_to]}/id_deploy", 'w')
      f.print(app[:deploy_key])
      f.close
    end
    not_if do File.exists?("#{app[:deploy_to]}/id_deploy"); end
  end

  file "#{app[:deploy_to]}/id_deploy" do
    owner app[:owner]
    group app[:group]
    mode 0600
  end

  template "#{app[:deploy_to]}/deploy-ssh-wrapper" do
    source 'deploy-ssh-wrapper.erb'
    owner app[:owner]
    group app[:group]
    mode 0755
    variables app.to_hash
  end
end

## Then, deploy
deploy_revision app[:id] do
  revision (app[:revision] || {})[node.app_environment] || 'HEAD'
  repository app[:repository]
  user app[:owner]
  group app[:group]
  deploy_to app[:deploy_to]
  action (app[:force] || {})[node.app_environment] ? :force_deploy : :deploy
  ssh_wrapper "#{app[:deploy_to]}/deploy-ssh-wrapper" if app[:deploy_key]
  migrate false
  symlink_before_migrate({})
  symlinks({})

  restart_command do
    execute 'nanoc3 compile' do
      command 'nanoc3 compile && rake deploy:rsync'
      user app[:owner]
      cwd "#{app[:deploy_to]}/current"
    end
  end
end
