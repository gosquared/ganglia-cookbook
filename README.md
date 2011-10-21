# DESCRIPTION

Installs and configures Ganglia. http://ganglia.sourceforge.net/

*GMOND*

Gathers user specified stats and shares them over the network.
It runs on every monitored node and itcomes with a number of native monitoring
 modules (disk, memory, network, etc). The gmond daemon never actually persists
any data (memory only) to optimize for speed. It can also receive data from
other gmond's, allowing us to build arbitrary hierarchies of nodes.

The gmond daemons are all responsible for periodically gathering and
distributing their stats upstream.

*GMETAD*

Responsible for collecting data from an arbitrary number of gmond's,
or even other gmetad daemons, persisting the metrics into correct RRD
(round robin database) files, and then making this data available to the
PHP frontend (or any other service that consumes RRD's).

*GANGLIA WEBFRONTEND*

PHP scripts which create the Ganglia front-end. Deployed behind the web
server (Apache, nginx etc.).

# REQUIREMENTS

* SELinux must be disabled on CentOS
* iptables must allow access to port 80

# USAGE

A run list with "recipe[ganglia]" enables monitoring.
A run list with "recipe[ganglia::web]" enables the web interface. It
includes the PHP front-end as well.

# CAVEATS

This cookbook has been tested on Ubuntu 10.04 and Centos 5.5.

# USE-CASE SCENARIO

Single grid (our company) with many clusters (web, routers, node.js servers & ruby servers).
`default_attributes` example from one of our web hosts (both run the
`ganglia::web` and collect stats from all other hosts, including themselves):

    :ganglia => {
      :gmetad => {
        :gridname => "gchef",
        :clusters => {
          :web => %w[127.0.0.1 x.x.x.x],
          :router => %w[x.x.x.x, x.x.x.x],
          :node => %w[x.x.x.x, x.x.x.x, x.x.x.x],
          :ruby => %w[x.x.x.x]
        }
      },
      :gmond => {
        :cluster_name => "web",
      }
    }

# LINKS

[Cluster Monitoring with Ganglia & Ruby](http://www.igvita.com/2010/01/28/cluster-monitoring-with-ganglia-ruby/)
