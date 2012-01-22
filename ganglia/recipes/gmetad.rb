case node[:platform]
when "ubuntu", "debian"
  %w{ rrdtool gmetad }.each do |pkg|
    package pkg
  end
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"
  execute "copy gmetad init script" do
    command "cp " +
      "/usr/src/ganglia-#{node[:ganglia][:version]}/gmetad/gmetad.init " +
      "/etc/init.d/gmetad"
    not_if "test -f /etc/init.d/gmetad"
  end
end

directory "/var/lib/ganglia/rrds" do
  owner "nobody"
  recursive true
end

query  = "recipes:ganglia AND ganglia_cluster_name:#{node['ganglia']['cluster_name']}"
hosts = search(:node, query).map do |n|
  # Get the ip
  n['network']['interfaces'][n['ganglia']['network_interface']]['addresses'].find {|a, i|
    i['family'] == 'inet'
  }.first
end

template "/etc/ganglia/gmetad.conf" do
  source "gmetad.conf.erb"
  variables({ :hosts => hosts })
  notifies :restart, "service[gmetad]"
end

service "gmetad" do
  supports :restart => true
  action [ :enable, :start ]
end
