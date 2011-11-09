define :ganglia_python_module, :disable => false do
  python_module = params[:name]
  available_modules = "/usr/lib/ganglia/python_modules_available"
  enabled_modules = "/usr/lib/ganglia/python_modules_enabled"

  link "#{enabled_modules}/#{python_module}.py" do
    to "#{available_modules}/#{python_module}/python_modules/#{python_module}.py"
    notifies :restart, resources(:service => "ganglia-monitor")
    action (params[:disable] ? :delete : :create)
  end

  link "#{enabled_modules}/#{python_module}.pyconf" do
    to "#{available_modules}/#{python_module}/conf.d/#{python_module}.pyconf"
    notifies :restart, resources(:service => "ganglia-monitor")
    action (params[:disable] ? :delete : :create)
  end
end
