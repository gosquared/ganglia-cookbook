apt_repository "ganglia" do
  uri "http://ppa.launchpad.net/rufustfirefly/ganglia/ubuntu"
  distribution `lsb_release -cs`.chomp
  components ["main"]
  key "A93EFBE2"
  action :add
end
