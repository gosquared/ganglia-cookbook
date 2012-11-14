case node[:platform]
when "ubuntu", "debian"
  package "gmetad"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"
  execute "copy gmetad init script" do
    command "cp " +
      "/usr/src/ganglia-#{node[:ganglia][:version]}/gmetad/gmetad.init " +
      "/etc/init.d/gmetad"
    not_if "test -f /etc/init.d/gmetad"
  end
end

execute "Ensure correct permissions for RRDs folder" do
  command %{
    mkdir -p #{node[:ganglia][:gmetad][:rrd_dir]}
    chown nobody.ganglia -fR #{node[:ganglia][:gmetad][:rrd_dir]}
  }
end

service "gmetad" do
  supports :start => true, :stop => true, :restart => true
  action :enable
end

template "/etc/ganglia/gmetad.conf" do
  source "gmetad.conf.erb"
  notifies :restart, resources(:service => "gmetad")
end
