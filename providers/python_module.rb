action :create do
  resolve_pip_dependencies
  setup_python_module_files
  setup_ganglia_python_module_config
end

action :delete do
  delete_python_module_files
  delete_ganglia_python_module_config
end

#################################################################### IMPLEMENTATION #

def python_package_dependencies
  node[:ganglia][:python_modules][new_resource.name.to_sym].fetch('pips') { {} }
end

def resolve_pip_dependencies
  python_package_dependencies.each do |pip_name, pip_version|
    python_pip pip_name do
      version pip_version
    end
  end
end

def python_module_files
  node[:ganglia][:python_modules][new_resource.name.to_sym].fetch('files') { [] } +
  ["#{new_resource.name}.py"]
end

def setup_python_module_files
  python_module_files.each do |file_name|
    template "#{node[:ganglia][:lib]}/python_modules/#{file_name}" do
      owner node[:ganglia][:gmond][:user]
      group node[:ganglia][:gmond][:user]
      mode "0554"
      cookbook "ganglia"
      source "python_modules/#{new_resource.name}/#{file_name}.erb"
      notifies :restart, resources(:service => "ganglia-monitor"), :delayed
    end
  end
end

def delete_python_module_files
  python_module_files.each do |file_name|
    file "#{node[:ganglia][:lib]}/python_modules/#{file_name}" do
      action :delete
      notifies :restart, resources(:service => "ganglia-monitor"), :delayed
    end
  end
end

def setup_ganglia_python_module_config
  template "#{node[:ganglia][:dir]}/conf.d/#{new_resource.name}.pyconf" do
    owner node[:ganglia][:gmond][:user]
    group node[:ganglia][:gmond][:user]
    mode "0664"
    cookbook "ganglia"
    source "python_modules/#{new_resource.name}/#{new_resource.name}.pyconf.erb"
    notifies :restart, resources(:service => "ganglia-monitor"), :delayed
  end
end

def delete_ganglia_python_module_config
  file "#{node[:ganglia][:dir]}/conf.d/#{new_resource.name}.pyconf" do
    action :delete
    notifies :restart, resources(:service => "ganglia-monitor"), :delayed
  end
end
