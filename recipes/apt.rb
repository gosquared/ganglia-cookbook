apt_repository "ganglia" do
  uri "http://ppa.launchpad.net/rufustfirefly/ganglia/ubuntu"
  keyserver "pgpkeys.mit.edu"
  key "A93EFBE2"
  action :add
end
