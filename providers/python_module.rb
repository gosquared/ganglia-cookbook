action :create do
 python_package_dependencies.each do |pip_name, pip_version|
  python_pip pip_name do
    version pip_version
  end
 end

  python_module_files.each do |file_name|
    template "#{node[:ganglia][:lib]}/python_modules/#{file_name}" do
      cookbook "ganglia"
      source "python_modules/#{new_resource.name}/#{file_name}.erb"
      notifies :restart, resources(:service => "ganglia-monitor"), :delayed
    end
  end

  template "#{node[:ganglia][:dir]}/conf.d/#{new_resource.name}.pyconf" do
    cookbook "ganglia"
    source "python_modules/#{new_resource.name}/#{new_resource.name}.pyconf.erb"
    notifies :restart, resources(:service => "ganglia-monitor"), :delayed
  end
end

action :delete do
  python_module_files.each do |file_name|
    file "#{node[:ganglia][:lib]}/python_modules/#{file_name}" do
      action :delete
      notifies :restart, resources(:service => "ganglia-monitor"), :delayed
    end
  end

  file "#{node[:ganglia][:dir]}/conf.d/#{new_resource.name}.pyconf" do
    action :delete
    notifies :restart, resources(:service => "ganglia-monitor"), :delayed
  end
end

def python_package_dependencies
  node[:ganglia][:python_modules][new_resource.name.to_sym].fetch('pips') { {} }
end

def python_module_files
  node[:ganglia][:python_modules][new_resource.name.to_sym].fetch('files') { [] } +
  ["#{new_resource.name}.py"]
end
