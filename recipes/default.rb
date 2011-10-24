case node[:platform]
when "ubuntu", "debian"
  package "ganglia-monitor"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"

  execute "copy ganglia-monitor init script" do
    command "cp " +
      "/usr/src/ganglia-#{node[:ganglia][:version]}/gmond/gmond.init " +
      "/etc/init.d/ganglia-monitor"
    not_if "test -f /etc/init.d/ganglia-monitor"
  end

  user "ganglia"
end

directory "/etc/ganglia"

service "ganglia-monitor" do
  pattern "gmond"
  supports :restart => true
  action [:enable, :start]
end

template "/etc/ganglia/gmond.conf" do
  source "gmond.conf.erb"
  notifies :restart, :service => "ganglia-monitor"
end
