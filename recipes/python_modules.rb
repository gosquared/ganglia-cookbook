if Chef::Util.respond_to?(:wan_up?)
  skip = Chef::Util.wan_up? ? false : true
else
  skip = false
end

unless skip
  git "/usr/lib/ganglia/python_modules_available" do
    repository "git://github.com/gchef/gmond_python_modules.git"
    reference "master"
    action :sync
  end

  directory "/usr/lib/ganglia/python_modules_enabled"

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
