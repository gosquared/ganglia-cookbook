directory "/usr/lib/ganglia/python_modules_enabled"

if Chef::Extensions.wan_up?
  git "/usr/lib/ganglia/python_modules_available" do
    repository node[:ganglia][:python_modules][:repository]
    reference "master"
    action :sync
  end

  template "/etc/ganglia/conf.d/modpython.conf" do
    cookbook "ganglia"
    source "modpython.conf.erb"
    notifies :restart, resources(:service => "ganglia-monitor")
  end

  node[:ganglia][:python_modules][:enabled].each do |python_module|
    ganglia_python_module python_module
  end

  node[:ganglia][:python_modules][:disabled].each do |python_module|
    ganglia_python_module python_module do
      disable true
    end
  end
end

template "/etc/ganglia/conf.d/python_modules.conf" do
  cookbook "ganglia"
  source "modpython.conf.erb"
  notifies :restart, resources(:service => "ganglia-monitor")
end
