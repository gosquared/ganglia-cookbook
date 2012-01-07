define :ganglia_python_module, :disable => false do
  python_module_path = params[:name]
  python_module_name = python_module_path.index("/") ? python_module_path.split("/")[-1] : python_module_path
  available_modules = "/usr/lib/ganglia/python_modules_available"
  enabled_modules = "/usr/lib/ganglia/python_modules_enabled"

  link "#{enabled_modules}/#{python_module_name}.py" do
    to "#{available_modules}/#{python_module_path}/python_modules/#{python_module_name}.py"
    notifies :restart, resources(:service => "ganglia-monitor")
    action (params[:disable] ? :delete : :create)
  end

  link "#{enabled_modules}/#{python_module_name}.pyconf" do
    to "#{available_modules}/#{python_module_path}/conf.d/#{python_module_name}.pyconf"
    notifies :restart, resources(:service => "ganglia-monitor")
    action (params[:disable] ? :delete : :create)
  end
end
