/*

== Class: tomcat::v5-5

Installs tomcat 5.5.X using the compressed archive from your favorite tomcat
mirror. Files from the archive will be installed in /opt/apache-tomcat/.

Class variables:
- *$log4j_conffile*: see tomcat

Requires:
- java to be previously installed
- common::archive definition (from puppet camptocamp/common module)
- Package["curl"]

Tested on:
- RHEL 5
- Debian Lenny

Parameters:
  $tomcat_version: The tomcat version you wish to install. Defaults to $tomcat::params::release_v55
  $mirror: URL of the closest tomcat mirror. Defaults to $tomcat::params::mirror

Usage:
  $tomcat_version = "5.5.23"
  include tomcat::v5-5

*/
class tomcat::v5-5 inherits tomcat {

  include tomcat::params

  if ( ! $tomcat_version ) {
    $tomcat_version = "${tomcat::params::release_v55}"
  }

  if ( ! $mirror ) {
    $mirror = "${tomcat::params::mirror}"
  }

  $baseurl   = "${mirror}/tomcat-5/v${tomcat_version}/bin"
  $tomcaturl = "${baseurl}/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive{ "apache-tomcat-${tomcat_version}":
    url         => $tomcaturl,
    digest_url  => "${tomcaturl}.md5",
    digest_type => "md5",
    target      => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
    require => Common::Archive["apache-tomcat-${tomcat_version}"],
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
