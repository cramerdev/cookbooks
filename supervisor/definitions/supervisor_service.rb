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

define :supervisor_service, :action => :enable do
  include_recipe 'supervisor'

  template "/etc/supervisor/conf.d/#{params[:name]}.conf" do
    cookbook 'supervisor'
    source 'supervisor_service.conf.erb'
    variables params
    owner 'root'
    group 'root'
    mode 0644
    notifies :restart, 'service[supervisor]'
  end
end
