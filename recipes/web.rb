case node[:platform]
when "ubuntu", "debian"
  package "ganglia-webfrontend" do
    options "--force-yes"
  end
when "redhat", "centos", "fedora"
  package "httpd"
  package "php"
  include_recipe "ganglia::source"
  include_recipe "ganglia::gmetad"

  execute "copy web directory" do
    command "cp -r web /var/www/html/ganglia"
    creates "/var/www/html/ganglia"
    cwd "/usr/src/ganglia-#{node[:ganglia][:version]}"
  end
end

# PHP templating...
# For some reason, ganglia-web doesn't include this
#
package "dwoo"
link "/usr/share/ganglia-webfrontend/dwoo" do
  to "/usr/share/php/dwoo"
end
# Dwoo requires this to write it's templates
#
directory "/var/lib/ganglia/dwoo" do
  owner "www-data"
  group "www-data"
  mode "0755"
end

directory "/etc/ganglia-webfrontend"

service "apache2" do
  service_name "httpd" if platform?( "redhat", "centos", "fedora" )
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

%w[cluster_legend node_legend].each do |filename|
  cookbook_file "/usr/share/ganglia-webfrontend/#{filename}.html" do
    cookbook "ganglia"
    source "#{filename}.html"
    owner "root"
    group "root"
    mode "0644"
  end
end

apache2_passwd "Ganglia user" do
  username node[:ganglia][:admin][:user]
  password node[:ganglia][:admin][:password]
  action :add
end
