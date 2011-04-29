#
# Cookbook Name:: supervisor
# Provider:: service
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

include Chef::Mixin::Command

sc = 'supervisorctl'

action :add do
  unless @s.enabled
    raise "command required" if new_resource.command.nil?

    # Convert environment hash to A=1,B=2,C=3
    env = new_resource.environment
    if env.kind_of?(Hash)
      new_resource.environment(env.map { |k, v| "#{k}=#{v}" }.join(','))
    end

    execute "supervisorctl update" do
      action :nothing
    end
    template "/etc/supervisor/conf.d/#{new_resource.name}.conf" do
      source 'service.conf.erb'
      # FIXME
      variables new_resource.to_hash
      mode '644'
      notifies :run, resources('execute[supervisorctl update]')
    end
    @s.enabled(true)
  end
end

action :remove do
  if @s.enabled
    execute "supervisorctl update" do
      action :nothing
    end
    file "/etc/supervisor/conf.d/#{new_resource.name}.conf" do
      action :delete
      notifies :run, resources('execute[supervisorctl update]')
    end
    @s.enabled(false)
  end
end

action :clear do
  if @s.enabled
    execute "#{sc} clear #{new_resource.name}"
  end
end

action :restart do
  if @s.enabled
    execute "#{sc} restart #{new_resource.name}"
  end
end

action :start do
  if @s.enabled && !@s.running
    execute "#{sc} start #{new_resource.name}"
  end
end

action :stop do
  if @s.enabled && @s.running
    execute "#{sc} stop #{new_resource.name}"
  end
end

action :update do
  execute "#{sc} update"
end

def load_current_resource
  n = new_resource.name
  @s = Chef::Resource::SupervisorService.new(n)
  @s.name(n)

  # Check enabled and running status
  status = output_of_command("supervisorctl status #{n}", {})[1]
  @s.enabled(status != "No such process #{n}")
  @s.running(status.split(/\s+/)[1] == 'RUNNING')
end
