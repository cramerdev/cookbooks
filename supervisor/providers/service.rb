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

# Reopen Chef's service resource and add support for variables
class ::Chef::Resource::Service
  def variables(arg = {})
    set_or_return(
      :variables,
      arg,
      :kind_of => [ Hash ]
    )
  end
end

include Chef::Mixin::Command

sc = 'supervisorctl'

action :enable do
  raise "start_command required" if new_resource.start_command.nil?

  new_resource.variables ||= {}

  # Convert environment hash to A=1,B=2,C=3
  env = new_resource.variables[:environment]
  if env.kind_of?(Hash)
    new_resource.variables[:environment] = env.map { |k, v| "#{k}=#{v}" }.join(',')
  end
  vars = resource_variables

  # Set program name if numprocs > 1
  if new_resource.variables[:num_procs].to_i > 1 && !new_resource.variables.key?(:process_name)
    new_resource.variables[:process_name] = '%(program_name)s_%(process_num)02d'
  end

  execute "supervisorctl update" do
    action :nothing
  end
  template "/etc/supervisor/conf.d/#{new_resource.name}.conf" do
    cookbook 'supervisor'
    source 'service.conf.erb'
    mode '644'
    variables vars
    notifies :run, resources('execute[supervisorctl update]')
  end
  @s.enabled(true)
end

action :disable do
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

# Default variables merged with the ones given, plus the arguments that map
# to config items
def resource_variables
  { :name                     => new_resource.service_name,
    :command                  => new_resource.start_command,
    :priority                 => new_resource.priority,
    :numprocs                 => 1,
    :numprocs_start           => 0,
    :priority                 => 999,
    :autostart                => true,
    :autorestart              => 'unexpected',
    :startsecs                => 1,
    :startretries             => 3,
    :exitcodes                => '0,2',
    :stopsignal               => 'TERM',
    :stopwaitsecs             => 10,
    :user                     => nil,
    :redirect_stderr          => false,
    :stdout_logfile           => 'AUTO',
    :stdout_logfile_maxbytes  => '50MB',
    :stdout_logfile_backups   => 10,
    :stdout_capture_maxbytes  => 0,
    :stdout_events_enabled    => 0,
    :stderr_logfile           => 'AUTO',
    :stderr_logfile_maxbytes  => '50MB',
    :stderr_logfile_backups   => 10,
    :stderr_capture_maxbytes  => 0,
    :stderr_events_enabled    => false,
    :environment              => nil,
    :directory                => nil,
    :umask                    => nil,
    :serverurl                => 'AUTO'
  }.merge(new_resource.variables || {})
end
