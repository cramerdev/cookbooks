#
# Cookbook Name:: postgresql
# Attributes:: pgpool
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

default['postgresql']['pgpool']['version'] = '3.1.1'
default['postgresql']['pgpool']['listen_addresses'] = '*'
default['postgresql']['pgpool']['child_max_connections'] = 0
default['postgresql']['pgpool']['log_destination'] = 'syslog'
default['postgresql']['pgpool']['load_balance_mode'] = 'off'
default['postgresql']['pgpool']['master_slave_mode'] = 'off'
default['postgresql']['pgpool']['master_slave_sub_mode'] = 'stream'
default['postgresql']['pgpool']['health_check_user'] = 'nobody'
default['postgresql']['pgpool']['delay_threshold'] = 10000000
default['postgresql']['pgpool']['pcp']['user_id'] = 'postgres'
default['postgresql']['pgpool']['pcp']['md5_password'] = ''
default['postgresql']['pgpool']['backends'] = []
