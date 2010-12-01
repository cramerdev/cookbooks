#
# Cookbook Name:: gearman
# Recipe:: server
#
# Copyright 2010, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "postgresql::server"

# Create user
user "gearman" do
  shell "/bin/bash"
  action :create
end

group "gearman" do
  members ["gearman"]
  append true
  action :create
end

# Add deploy keys
directory "/home/gearman/.ssh" do
  owner "gearman"
  group "gearman"
  mode "0700"
end

cookbook_file "/home/gearman/.ssh/id_rsa" do
  backup false
  owner "gearman"
  group "gearman"
  mode "0600"
end

cookbook_file "/home/gearman/.ssh/id_rsa.pub" do
  backup false
  owner "gearman"
  group "gearman"
  mode "0600"
end

# Git clone
git node[:gearman][:server][:path] do
  repository node[:gearman][:server][:repo]
  user "gearman"
  group "gearman"
  action :sync
end

# Database config
# TODO: Configure database with attributes
template node[:gearman][:server][:path] + "/config/database.yml" do
  source "database.yml.erb"
  owner "gearman"
  group "gearman"
  mode "0644"
end

# Bundle
bash "bundle install" do
  cwd node[:gearman][:server][:path]
  code "bundle install --deployment"
  creates node[:gearman][:server][:path] + "/vendor/bundle"
  user "gearman"
  group "gearman"
end
