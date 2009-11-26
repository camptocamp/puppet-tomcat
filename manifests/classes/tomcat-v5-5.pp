/*

== Class: tomcat::v5-5

Installs tomcat 5.5.X using the compressed archive from your favorite tomcat
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
  $tomcat_version: The tomcat version you wish to install. Currently defaults to "5.5.27".
  $mirror: URL of the closest tomcat mirror. Defaults to mirror.switch.ch.

Usage:
  $tomcat_version = "5.5.23"
  include tomcat::v5-5

*/
class tomcat::v5-5 inherits tomcat {

  if ( ! $tomcat_version ) {
    $tomcat_version = "5.5.27"
  }

  if ( ! $mirror ) {
    $mirror = "http://mirror.switch.ch/mirror/apache/dist/tomcat/"
  }

  $url = "${mirror}/tomcat-5/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive::tar-gz{"/opt/apache-tomcat-${tomcat_version}/.installed":
    source => $url,
    target => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
    require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
    before  => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  File["commons-logging.jar"] {
    path => "/opt/apache-tomcat/common/lib/commons-logging.jar",
  }

  File["log4j.jar"] {
    path => "/opt/apache-tomcat/common/lib/log4j.jar",
  }

  File["log4j.properties"] {
    path => "/opt/apache-tomcat/common/classes/log4j.properties",
  }

}
