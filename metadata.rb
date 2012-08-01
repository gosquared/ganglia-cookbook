maintainer       "Gerhard Lazu"
maintainer_email "gerhard@lazu.co.uk"
license          "Apache 2.0"
description      "Installs/Configures ganglia"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.2"

supports "debian"
supports "ubuntu"
supports "redhat"
supports "centos"
supports "fedora"

# RECOMMENDED     # https://github.com/gchef/bootstrap-cookbook
depends "apt"     # https://github.com/gchef/apt-cookbook
depends "apache2" # https://github.com/gosquared/apache2-cookbook
depends "php"     # https://github.com/gchef/php-cookbook
