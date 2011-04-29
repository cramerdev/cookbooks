#
# Cookbook Name:: supervisor
# Definition:: supervisor_service
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

define :supervisor_service,
       :environment => {},
       :action => :enable do

  include_recipe 'supervisor'

  act = params[:action].to_sym
  env = params[:environment]
  name = params[:name]

  # Enable will install the service and templated configuration file
  if act == :enable
    raise 'command is required' if params[:command].nil?

    execute 'update supervisor configuration' do
      command "supervisorctl update #{name}"
      action :nothing
    end

    # Convert environment hash to A=1,B=2,C=3
    if env.is_a?(Hash)
      params[:environment] = env.map { |k, v| "#{k}=#{v}" }.join(',')
    end

    template "/etc/supervisor/conf.d/#{name}.conf" do
      cookbook 'supervisor'
      source 'supervisor_service.conf.erb'
      variables params
      owner 'root'
      group 'root'
      mode 0644
      notifies :run, resources(:execute => 'update supervisor configuration')
    end

    # Handle other action parameters by passing it along to supervisorctl
  elsif act != :nothing
    execute "supervisorctl #{action} #{name}"
  end
end
