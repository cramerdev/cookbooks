#
# Cookbook Name:: supervisor
# Resource:: service
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

actions :add, :remove, :clear, :remove, :restart, :start, :stop, :update

attribute :name, :name_attribute => true
attribute :enabled, :default => false
attribute :running, :default => false

attribute :command, :kind_of => String
attribute :process_name, :kind_of => String, :default => '%(program_name)s'
attribute :numprocs, :kind_of => Fixnum, :default => 1
attribute :numprocs_start, :kind_of => Fixnum, :default => 0
attribute :priority, :kind_of => Fixnum, :default => 999
attribute :autostart, :equal_to => [true, false], :default => true
attribute :autorestart, :equal_to => [true, false, 'unexpected'],
                        :default  => 'unexpected'
attribute :startsecs, :kind_of => Fixnum, :default => 1
attribute :startretries, :kind_of => Fixnum, :default => 3
attribute :exitcodes, :kind_of => String, :default => '0,2'
attribute :stopsignal, :kind_of  => String,
                       :equal_to => ['TERM', 'HUP', 'INT', 'QUIT', 'KILL',
                                     'USR1', 'USR2'],
                       :default  => 'TERM'
attribute :stopwaitsecs, :kind_of => Fixnum, :default => 10
attribute :user, :default => nil
attribute :redirect_stderr, :equal_to => [true, false], :default => false
attribute :stdout_logfile, :kind_of => String, :default => 'AUTO'
attribute :stdout_logfile_maxbytes, :default => '50MB'
attribute :stdout_logfile_backups, :kind_of => Fixnum, :default => 10
attribute :stdout_capture_maxbytes, :default => 0
attribute :stdout_events_enabled, :default => 0
attribute :stderr_logfile, :kind_of => String, :default => 'AUTO'
attribute :stderr_logfile_maxbytes, :default => '50MB'
attribute :stderr_logfile_backups, :kind_of => Fixnum, :default => 10
attribute :stderr_capture_maxbytes, :default => 0
attribute :stderr_events_enabled, :default => false
attribute :environment, :default => nil
attribute :directory, :default => nil
attribute :umask, :default => nil
attribute :serverurl, :kind_of => String, :default => 'AUTO'

# Set default actions on initialize
def initialize(*args)
  super
  @action = [:add, :start]
end
