# Not using the packaged version because that depends on apache. Some might prefer nginx.
#
remote_file node[:ganglia][:web][:save_to] do
  checksum node[:ganglia][:web][:checksum]
  source node[:ganglia][:web][:uri]
  action :create_if_missing
end

directory "/var/lib/ganglia/conf"
directory "/var/lib/ganglia/dwoo"
directory "/var/lib/ganglia/dwoo/cache" do
  owner "www-data"
  group "www-data"
  mode "0774"
end
directory "/var/lib/ganglia/dwoo/compiled" do
  owner "www-data"
  group "www-data"
  mode "0774"
end

bash "Installing Ganglia Web #{node[:ganglia][:web][:version]}" do
  cwd node[:ganglia][:web][:save_to_basepath]
  code %{
    tar zxf #{node[:ganglia][:web][:archive_name]}
    mv #{node[:ganglia][:web][:dir_name]} /var/www/#{node[:ganglia][:web][:dir_name]}
    cp -fR /var/www/#{node[:ganglia][:web][:dir_name]}/conf/*.json /var/lib/ganglia/conf
    rm -fr /var/lib/ganglia/dwoo/*
  }
  only_if "[ ! -d /var/www/#{node[:ganglia][:web][:dir_name]} ]"
end

template "/var/www/#{node[:ganglia][:web][:dir_name]}/conf_default.php" do
  cookbook "ganglia"
  source "web/conf_default.php.erb"
end

execute "Ensuring correct permissions for #{node[:ganglia][:web][:dir_name]}" do
  command %{
    chown www-data. -fR /var/www/#{node[:ganglia][:web][:dir_name]}
    chown www-data. -fR /var/lib/ganglia/conf
    chown www-data. -fR /var/lib/ganglia/dwoo
  }
end

apache2_passwd node[:ganglia][:web][:username] do
  password node[:ganglia][:web][:password]
  action :add
end

template "/etc/apache2/sites-available/#{node[:ganglia][:web][:server_name]}-ssl" do
  cookbook "ganglia"
  source "web/ganglia-web.apache-ssl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
apache_site "#{node[:ganglia][:web][:server_name]}-ssl"

template "/etc/apache2/sites-available/#{node[:ganglia][:web][:server_name]}" do
  cookbook "ganglia"
  source "web/ganglia-web.apache.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
apache_site "#{node[:ganglia][:web][:server_name]}"

default_view_items = []
node[:ganglia][:web][:views][:enabled].each do |view|
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

node[:ganglia][:web][:views][:disabled].each do |view|
  ganglia_view view do
    action :remove
  end
end
