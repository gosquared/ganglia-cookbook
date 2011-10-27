remote_file node[:ganglia][:web2][:save_to] do
  checksum "e42309b9dbcd65886db8bfa0eee0dc47a379d90cae1812790ca372b6939c775b"
  source node[:ganglia][:web2][:uri]
  action :create_if_missing
end

directory "/var/lib/ganglia/conf"

bash "Installing Ganglia Web #{node[:ganglia][:web2][:version]}" do
  cwd node[:ganglia][:web2][:save_to_basepath]
  code %{
    tar zxf #{node[:ganglia][:web2][:archive_name]}
    mv #{node[:ganglia][:web2][:dir_name]} /var/www
    cp -fR /var/www/#{node[:ganglia][:web2][:dir_name]}/conf/*.json /var/lib/ganglia/conf
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
  }
end

template "/etc/apache2/sites-available/#{node[:ganglia][:web2][:server_name]}" do
  cookbook "ganglia"
  source "web2/gweb2.apache-ssl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end
apache_site node[:ganglia][:web2][:server_name]
