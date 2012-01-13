service "ganglia-monitor" do
  pattern "gmond"
end

directory "/etc/ganglia"
directory "/etc/ganglia/conf.d"

# If this wasn't created before the package is installed,
# the service would start with the wrong config
#
# This should work, but I can't get past:
# Configuration file `/etc/ganglia/gmond.conf'
#  ==> File on system created by you or by a script.
#  ==> File also in package provided by package maintainer.
#    What would you like to do about it ?  Your options are:
#     Y or I  : install the package maintainer's version
#     N or O  : keep your currently-installed version
#       D     : show the differences between the versions
#       Z     : background this process to examine the situation
#  The default action is to keep your current version.
# *** gmond.conf (Y/I/N/O/D/Z) [default=N] ?
#
# template "/etc/ganglia/gmond.conf" do
#   cookbook "ganglia"
#   source "gmond.conf.erb"
#   notifies :restart, resources(:service => "ganglia-monitor"), :delayed
# end

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
