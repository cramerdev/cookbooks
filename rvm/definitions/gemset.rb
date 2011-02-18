#
# Cookbook Name:: rvm
# Definition:: gemset
#
# Copyright 2011, Cramer Development, Inc.
#
# All rights reserved
#

define :gemset, :action => :create, :user => 'root', :group => 'rvm',
       :ruby => nil do

  ruby = params[:ruby] || (node[:rvm] || {})[:ruby]

  ruby_version = [].tap do |v|
    v << ruby[:implementation] if ruby[:implementation]
    v << ruby[:version] if ruby[:version]
    v << "p#{ruby[:patch_level]}" if ruby[:patch_level]
  end * '-'

  if params[:action] == :create
    execute "rvm use #{ruby_version} && rvm gemset create #{params[:name]}" do
      user params[:user]
      group params[:group]
      creates "/usr/local/rvm/gems/#{ruby_version}@#{params[:name]}"
    end
  end
end
