default[:ganglia][:version]   = "3.2.0"
default[:ganglia][:uri]       = "http://sourceforge.net/projects/ganglia/files/ganglia%20monitoring%20core/#{ganglia[:version]}/ganglia-#{ganglia[:version]}.tar.gz/download"
default[:ganglia][:checksum]  = "9867153c550a65099544fae82ff3514e4ae8b172a360e4b5320e269eb32dae48"

default[:ganglia][:gmetad][:grid_name] = "default-grid"
default[:ganglia][:gmetad][:clusters]  = {}

default[:ganglia][:gmond][:cluster_name] = "default-cluster"
#
# Minimum amount of time before gmond will cleanup expired data
default[:ganglia][:gmond][:cleanup_threshold] = 300
#
# Time to flush the host from gmond's list after N seconds
# By default it will not remove any hosts
default[:ganglia][:gmond][:host_dmax] = 0

default[:ganglia][:admin][:user] = "ganglia"
default[:ganglia][:admin][:password] = "ChangeMeNOW!!!"
