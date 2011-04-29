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
  raise "command required" if new_resource.command.nil?

  # Convert environment hash to A=1,B=2,C=3
  env = new_resource.environment
  if env.kind_of?(Hash)
    new_resource.environment(env.map { |k, v| "#{k}=#{v}" }.join(','))
  end

  # Get the merged attributes
  attrs = resource_attributes

  execute "supervisorctl update" do
    action :nothing
  end
  template "/etc/supervisor/conf.d/#{new_resource.name}.conf" do
    source 'service.conf.erb'
    mode '644'
    variables attrs
    notifies :run, resources('execute[supervisorctl update]')
  end
  @s.enabled(true)
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

private

# This is a hack. I for the life of me can't figure out how to get the default
# attributes from the resource, so this just lists them all out, puts their
# values in a hash, and merges them with the actual given values.
def resource_attributes
  attrs = %w{ command process_name numprocs numprocs_start priority autostart
              autorestart startsecs startretries exitcodes stopsignal
              stopwaitsecs user redirect_stderr stdout_logfile
              stdout_logfile_maxbytes stdout_logfile_backups
              stdout_capture_maxbytes stdout_events_enabled stderr_logfile
              stderr_logfile_maxbytes stderr_logfile_backups
              stderr_capture_maxbytes stderr_events_enabled environment
              directory umask serverurl }
  h = {}
  attrs.each do |attr|
    h[attr.to_sym] = new_resource.send(attr)
  end
  h.merge(new_resource.to_hash)
end
