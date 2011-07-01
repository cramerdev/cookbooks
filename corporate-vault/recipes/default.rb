#
# Cookbook Name:: corporate-vault
# Recipe:: default
#
# Copyright 2011, Cramer Development, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'java'
include_recipe 'supervisor'

# Shortcut - because I don't like to type and can't spell "corporate"
cv = "corporatevault"

# Native Tomcat support
#
# We *want* to have this installed, but the thing won't run with it installed.
# There's some kind of ipv6-related but in the ubuntu distribution. So, if
# libtcnative-1 <= 1.1.19 is installed this won't run, but we don't want to
# remove it in case something else depends on it.
#
# if node[:platform] == 'ubuntu' || node[:platform] == 'debian'
#   package 'libtcnative-1'
# end

user cv do
  home "/home/#{cv}"
  supports :manage_home => true
end

remote_file "/usr/src/#{cv}-0.6.7.tar.gz" do
  source "http://downloads.sourceforge.net/project/#{cv}/#{cv}/RELEASE_v_0_6_7/tomcat-#{cv}-0.6.7.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2F#{cv}%2F&ts=1308328599&use_mirror=cdnetworks-us-2"
  action :create_if_missing
end

execute "tar xfz /usr/src/#{cv}-0.6.7.tar.gz && mv /usr/src/tomcat /home/#{cv}/#{cv} && chown -R #{cv}:#{cv} /home/#{cv}/#{cv}" do
  cwd '/usr/src'
  creates "/home/#{cv}/#{cv}"
end

directory "/home/#{cv}/backup" do
  owner "#{cv}"
  group "#{cv}"
  mode '0700'
end

supervisor_service "#{cv}" do
  start_command "/home/#{cv}/#{cv}/bin/catalina.sh run"
  variables :directory => "/home/#{cv}/#{cv}",
            :user      => "#{cv}"
end
