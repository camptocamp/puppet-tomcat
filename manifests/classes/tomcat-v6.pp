/*

== Class: tomcat::v6

Installs tomcat 6.0.X using the compressed archive from your favorite tomcat
mirror. Files from the archive will be installed in /opt/apache-tomcat/.

Requires:
- java to be previously installed
- common::archive::tar-gz definition (from puppet Common module)
- Package["curl"]

Tested on:
- RHEL 5
- Debian Lenny

Parameters:
  $tomcat_version: The tomcat version you wish to install. Currently defaults to "6.0.20".
  $mirror: URL of the closest tomcat mirror. Defaults to mirror.switch.ch.

Usage:
  $tomcat_version = "6.0.18"
  include tomcat::v6

*/
class tomcat::v6 inherits tomcat {

  if ( ! $tomcat_version ) {
    $tomcat_version = "6.0.20"
  }

  if ( ! $mirror ) {
    $mirror = "http://mirror.switch.ch/mirror/apache/dist/tomcat/"
  }

  $url = "${mirror}/tomcat-6/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive::tar-gz{"/opt/apache-tomcat-${tomcat_version}/.installed":
    source => $url,
    target => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
    require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
  }

  # Workarounds
  case $tomcat_version {
    "6.0.18": {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"/opt/apache-tomcat-${tomcat_version}/bin/catalina.sh":
        ensure  => present,
        source  => "puppet:///tomcat/catalina.sh-6.0.18",
        require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
        mode => "755",
      }
    }
  }
}
