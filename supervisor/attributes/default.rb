#
# Author:: Nathan L Smith <nathan@cramerdev.com>
# Cookbook Name:: supervisor
# Attributes:: default
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

default['supervisor']['group'] = 'supervisor'

default['supervisor']['inet_http_server']['enabled'] = false
default['supervisor']['inet_http_server']['username'] = nil
default['supervisor']['inet_http_server']['password'] = nil
default['supervisor']['inet_http_server']['ipaddress'] = node['ipaddress']
default['supervisor']['inet_http_server']['port'] = '9001'
