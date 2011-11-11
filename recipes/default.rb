case node[:platform]
when "ubuntu", "debian"
  include_recipe "ganglia::apt"
  package "rrdtool"
  package "ganglia-monitor"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"

  execute "copy ganglia-monitor init script" do
    command %x{
      cp /usr/src/ganglia-#{node[:ganglia][:version]}/gmond/gmond.init /etc/init.d/ganglia-monitor
    }
    not_if "[ -f /etc/init.d/ganglia-monitor ]"
  end

  user "ganglia"
end

directory "/etc/ganglia"
directory "/etc/ganglia/conf.d"

service "ganglia-monitor" do
  pattern "gmond"
  supports :restart => true
  action [:enable, :start]
end

template "/etc/ganglia/gmond.conf" do
  cookbook "ganglia"
  source "gmond.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor")
end

template "/etc/ganglia/conf.d/gmond.modules.conf" do
  cookbook "ganglia"
  source "gmond.modules.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor")
end

template "/etc/ganglia/conf.d/gmond.collection_groups.conf" do
  cookbook "ganglia"
  source "gmond.collection_groups.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor")
end
