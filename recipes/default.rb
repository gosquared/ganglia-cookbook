user node[:ganglia][:gmond][:user]

service "ganglia-monitor" do
  pattern "gmond"
end

directory "/etc/ganglia" do
  owner node[:ganglia][:gmond][:user]
  group node[:ganglia][:gmond][:user]
  mode "0755"
end

directory "/etc/ganglia/conf.d" do
  owner node[:ganglia][:gmond][:user]
  group node[:ganglia][:gmond][:user]
  mode "0755"
end

# If this wasn't created before the package is installed,
# the service would start with the wrong config
template "/etc/ganglia/gmond.conf" do
  owner node[:ganglia][:gmond][:user]
  group node[:ganglia][:gmond][:user]
  mode "0554"
  cookbook "ganglia"
  source "gmond.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor"), :delayed
end

case node[:platform]
when "ubuntu", "debian"
  include_recipe "ganglia::apt"
  package "rrdtool"
  package "ganglia-monitor" do
    version "#{node[:ganglia][:version]}*"
    options '--force-yes -o Dpkg::Options::="--force-confold"'
    only_if "[ $(dpkg -l ganglia-monitor 2>&1 | grep #{node[:ganglia][:version]}.* | grep -c '^h[ic] ') = 0 ]"
  end

  bash "freeze ganglia-monitor package" do
    code "echo ganglia-monitor hold | dpkg --set-selections"
    only_if "[ $(dpkg --get-selections | grep 'ganglia-monitor' | grep -c 'hold') = 0 ] "
  end

when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"

  execute "copy ganglia-monitor init script" do
    command %x{
      cp /usr/src/ganglia-#{node[:ganglia][:version]}/gmond/gmond.init /etc/init.d/ganglia-monitor
    }
    not_if "[ -f /etc/init.d/ganglia-monitor ]"
  end
end

service "ganglia-monitor" do
  pattern "gmond"
end

template "/etc/ganglia/gmond.conf" do
  cookbook "ganglia"
  source "gmond.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor"), :delayed
end

template "/etc/ganglia/conf.d/gmond.modules.conf" do
  cookbook "ganglia"
  source "gmond.modules.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor"), :delayed
end

template "/etc/ganglia/conf.d/gmond.collection_groups.conf" do
  cookbook "ganglia"
  source "gmond.collection_groups.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor"), :delayed
end
