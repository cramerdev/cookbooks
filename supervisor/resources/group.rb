#
# Cookbook Name:: supervisor
# Resource:: group
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

actions :disable, :restart, :start, :stop, :update

attribute :group_name, :name_attribute => true
attribute :programs, :kind_of => Array, :required => true
attribute :priority, :kind_of => Fixnum, :default => 999
attribute :supports, :kind_of => Hash, :default => { :restart => true,
                                                     :disable => true,
                                                     :start   => true,
                                                     :stop    => true,
                                                     :update  => true }

# Set default actions on initialize
def initialize(*args)
  super
  @action = [:enable]
end
