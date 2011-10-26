maintainer       "Gerhard Lazu"
maintainer_email "gerhard@lazu.co.uk"
license          "Apache 2.0"
description      "Installs/Configures ganglia"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.2.0"

supports "debian"
supports "ubuntu"
supports "redhat"
supports "centos"
supports "fedora"

depends "apt"
depends "apache2"
depends "php"
