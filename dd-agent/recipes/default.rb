#
# Cookbook Name:: dd-agent
# Recipe:: default
#
# Copyright 2011, Datadog, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Skip to "HERE HERE HERE" below for user configurable data

# Only support Debian & Ubuntu (RedHat et al. coming soon)
case node.platform
when "debian", "ubuntu"
    # Get the key
    execute "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52" do
      not_if "apt-key list | grep C7A7DA52"
    end

    # Add the repo
    cookbook_file "/etc/apt/sources.list.d/datadog.list" do
        owner "root"
        group "root"
        mode 0755
    end

    # Update the repo
    execute "apt-get update"

    package "datadog-agent"

    service "datadog-agent" do
        action :nothing
        supports :restart => true
    end

    directory "/etc/dd-agent" do
        owner "root"
        group "root"
        mode 0755
    end

    template "/etc/dd-agent/datadog.conf" do
        owner "root"
        group "root"
        mode 0644
        #
        # HERE HERE HERE Replace the placeholder below with your api key
        variables(:api_key => "REPLACE_ME_WITH_YOUR_API_KEY", :dd_url => "https://app.datadoghq.com")
        # You are done! No need to touch the rest of the file
        #
        notifies :restart, "service[datadog-agent]", :immediately
    end
end
