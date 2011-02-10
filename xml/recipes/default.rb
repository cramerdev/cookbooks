#
# Cookbook Name:: xml
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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

case node[:platform]
when "ubuntu","debian"
  package "libxml2-utils" do
    action :install
  end
when "centos","redhat"
  package "libxml2" do
    action :install
  end
end

package "libxml-devel" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse", "fedora" ] => { "default" => "libxml2-devel" },
    "default" => 'libxml2-dev'
  )
end

package "libxslt1-dev" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse", "fedora" ] => { "default" => "libxslt-devel" },
    "default" => 'libxslt1-dev'
  )
end
