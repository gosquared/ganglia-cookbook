package "python"
package "python-dev"
package "python-pip"

directory "#{node[:ganglia][:lib]}/python_modules"

template "#{node[:ganglia][:dir]}/conf.d/python.modules.conf" do
  cookbook "ganglia"
  notifies :restart, resources(:service => "ganglia-monitor"), :delayed
end

node[:ganglia][:python_modules].each do |module_name, module_attributes|
  ganglia_python_module module_name do
    action (module_attributes[:status] == :enabled ? :create : :delete)
  end
end



### CLEANUP
#
directory "#{node[:ganglia][:lib]}/python_modules_available" do
  action :delete
  recursive true
end

directory "#{node[:ganglia][:lib]}/python_modules_enabled" do
  action :delete
  recursive true
end

file "#{node[:ganglia][:dir]}/conf.d/modpython.conf" do
  action :delete
end

file "#{node[:ganglia][:dir]}/conf.d/python_modules.conf" do
  action :delete
end

file "#{node[:ganglia][:dir]}/conf.d/pythonmodules.conf" do
  action :delete
end

bash "Remove all python modules symlinks" do
  code %{
    ls #{node[:ganglia][:lib]}/python_modules | while read file
    do
      if [ -L $file ]
      then
        rm -f $file
      fi
    done
  }
end
