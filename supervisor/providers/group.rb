#
# Cookbook Name:: supervisor
# Provider:: group
#
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

include Chef::Mixin::Command

sc = 'supervisorctl'

action :enable do
  execute "supervisorctl update" do
    action :nothing
  end

  template "/etc/supervisor/conf.d/#{new_resource.name}_group.conf" do
    cookbook 'supervisor'
    source 'group.conf.erb'
    variables(new_resource.to_hash)
    mode '0644'
    notifies :run, resources('execute[supervisorctl update]')
  end
end

action :disable do
  execute "supervisorctl update" do
    action :nothing
  end

  file "/etc/supervisor/conf.d/#{new_resource.name}_group.conf" do
    action :delete
    notifies :run, resources('execute[supervisorctl update]')
  end
end

action :restart do
  execute "#{sc} restart #{new_resource.name}:*"
end

action :start do
  execute "#{sc} start #{new_resource.name}:*"
end

action :stop do
  execute "#{sc} stop #{new_resource.name}:*"
end

action :update do
  execute "#{sc} update"
end

def load_current_resource
  n = new_resource.name
  @s = Chef::Resource::SupervisorGroup.new(n)
  @s.name(n)
end
