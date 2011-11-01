remote_file node[:ganglia][:web2][:save_to] do
  checksum node[:ganglia][:web2][:checksum]
  source node[:ganglia][:web2][:uri]
  action :create_if_missing
end

directory "/var/lib/ganglia/conf"
directory "/var/lib/ganglia/dwoo"

bash "Installing Ganglia Web #{node[:ganglia][:web2][:version]}" do
  cwd node[:ganglia][:web2][:save_to_basepath]
  code %{
    tar zxf #{node[:ganglia][:web2][:archive_name]}
    mv #{node[:ganglia][:web2][:dir_name]} /var/www/#{node[:ganglia][:web2][:dir_name]}
    cp -fR /var/www/#{node[:ganglia][:web2][:dir_name]}/conf/*.json /var/lib/ganglia/conf
    rm -fr /var/lib/ganglia/dwoo/*
  }
  only_if "[ ! -d /var/www/#{node[:ganglia][:web2][:dir_name]} ]"
end

template "/var/www/#{node[:ganglia][:web2][:dir_name]}/conf_default.php" do
  cookbook "ganglia"
  source "web2/conf_default.php.erb"
end

execute "Ensuring correct permissions for #{node[:ganglia][:web2][:dir_name]}" do
  command %{
    chown www-data. -fR /var/www/#{node[:ganglia][:web2][:dir_name]}
    chown www-data. -fR /var/lib/ganglia/conf
    chown www-data. -fR /var/lib/ganglia/dwoo
  }
end

apache2_passwd "Ganglia user" do
  username node[:ganglia][:admin][:user]
  password node[:ganglia][:admin][:password]
  action :add
end

template "/etc/apache2/sites-available/#{node[:ganglia][:web2][:server_name]}-ssl" do
  cookbook "ganglia"
  source "web2/gweb2.apache-ssl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
apache_site "#{node[:ganglia][:web2][:server_name]}-ssl"

default_view_items = []
node[:ganglia][:web2][:views][:enabled].each do |view|
  view[:items].each { |item| default_view_items << item }

  ganglia_view view[:name] do
    type view[:type]
    items view[:items]
    action :create
  end
end

ganglia_view "default" do
  items default_view_items
  action :create
end

node[:ganglia][:web2][:views][:disabled].each do |view|
  ganglia_view view do
    action :remove
  end
end
