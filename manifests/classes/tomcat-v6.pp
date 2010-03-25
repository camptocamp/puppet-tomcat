/*

== Class: tomcat::v6

Installs tomcat 6.0.X using the compressed archive from your favorite tomcat
mirror. Files from the archive will be installed in /opt/apache-tomcat/.

Class variables:
- *$log4j_conffile*: see tomcat

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
    $tomcat_version = "6.0.24"
  }

  if ( ! $mirror ) {
    $mirror = "http://mirror.switch.ch/mirror/apache/dist/tomcat/"
  }

  $baseurl   = "${mirror}/tomcat-6/v${tomcat_version}/bin/"
  $tomcaturl = "${baseurl}/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive::tar-gz{"/opt/apache-tomcat-${tomcat_version}/.installed":
    source => $tomcaturl,
    target => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
    require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
    before  => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  # configuring logging on tomcat6 requires 2 files from the extra components
  # see: http://tomcat.apache.org/tomcat-6.0-doc/logging.html
  file { "/opt/apache-tomcat-${tomcat_version}/extras/":
    ensure  => directory,
    require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
  }

  exec { "fetch tomcat-juli.jar":
    command => "curl -o /opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli.jar ${baseurl}/extras/tomcat-juli.jar",
    creates => "/opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli.jar",
    require => File["/opt/apache-tomcat-${tomcat_version}/extras/"],
  }

  exec { "fetch tomcat-juli-adapters.jar":
    command => "curl -o /opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli-adapters.jar ${baseurl}/extras/tomcat-juli-adapters.jar",
    creates => "/opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli-adapters.jar",
    require => File["/opt/apache-tomcat-${tomcat_version}/extras/"],
  }

  # update tomcat-juli.jar with file downloaded from extras/
  file { "/opt/apache-tomcat-${tomcat_version}/bin/tomcat-juli.jar":
    ensure  => link,
    target  => "/opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli.jar",
    require => Exec["fetch tomcat-juli.jar"],
  }

  file { "/opt/apache-tomcat-${tomcat_version}/lib/tomcat-juli-adapters.jar":
    ensure  => link,
    target  => "/opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli-adapters.jar",
    require => Exec["fetch tomcat-juli-adapters.jar"],
  }


  File["commons-logging.jar"] {
    path => "/opt/apache-tomcat/lib/commons-logging.jar",
  }

  File["log4j.jar"] {
    path => "/opt/apache-tomcat/lib/log4j.jar",
  }

  File["log4j.properties"] {
    path => "/opt/apache-tomcat/lib/log4j.properties",
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
