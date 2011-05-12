# Cookbook Name:: git
# Recipe:: utils
#
# Copyright 2008-2009, Opscode, Inc.
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

%w{ git-up grb }.each do |pkg|
  gem_package pkg do
    action :install
  end
end

# Git Flow
remote_file "/usr/src/gitflow-install.sh" do
  source "http://github.com/nvie/gitflow/raw/develop/contrib/gitflow-installer.sh"
  owner "root"
  mode 0755
end

execute "gitflow-install" do
  command "/usr/src/gitflow-install.sh"
  action :run
  creates "/usr/local/bin/git-flow"
end

# Git Flow Completion
remote_file "/etc/bash_completion.d/git-flow" do
  action :create_if_missing
  source 'https://github.com/bobthecow/git-flow-completion/raw/master/git-flow-completion.bash'
  owner 'root'
  mode 0755
end
