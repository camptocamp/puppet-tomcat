/*

== Class: tomcat::v6

Installs tomcat 6.0.X using the compressed archive from your favorite tomcat
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
  $tomcat_version: The tomcat version you wish to install. Defaults to $tomcat::params::release_v6
  $mirror: URL of the closest tomcat mirror. Defaults to $tomcat::params::mirror

Usage:
  $tomcat_version = "6.0.18"
  include tomcat::v6

*/
class tomcat::v6 inherits tomcat {

  include tomcat::params

  if ( ! $tomcat_version ) {
    $tomcat_version = "${tomcat::params::release_v6}"
  }

  if ( ! $mirror ) {
    $mirror = "${tomcat::params::mirror}"
  }

  $baseurl   = "${mirror}/tomcat-6/v${tomcat_version}/bin"
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

  # configuring logging on tomcat6 requires 2 files from the extra components
  # see: http://tomcat.apache.org/tomcat-6.0-doc/logging.html
  file { "/opt/apache-tomcat-${tomcat_version}/extras/":
    ensure  => directory,
    require => Common::Archive["apache-tomcat-${tomcat_version}"],
  }

  common::archive::download { "tomcat-juli.jar":
    url         => "${baseurl}/extras/tomcat-juli.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli.jar.md5",
    digest_type => "md5",
    src_target  => "/opt/apache-tomcat-${tomcat_version}/extras/",
    require     => File["/opt/apache-tomcat-${tomcat_version}/extras/"],
  }

  common::archive::download { "tomcat-juli-adapters.jar":
    url         => "${baseurl}/extras/tomcat-juli-adapters.jar",
    digest_url  => "${baseurl}/extras/tomcat-juli-adapters.jar.md5",
    digest_type => "md5",
    src_target  => "/opt/apache-tomcat-${tomcat_version}/extras/",
    require     => File["/opt/apache-tomcat-${tomcat_version}/extras/"],
  }

  # update tomcat-juli.jar with file downloaded from extras/
  file { "/opt/apache-tomcat-${tomcat_version}/bin/tomcat-juli.jar":
    ensure  => link,
    target  => "/opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli.jar",
    require => Common::Archive::Download["tomcat-juli.jar"],
  }

  file { "/opt/apache-tomcat-${tomcat_version}/lib/tomcat-juli-adapters.jar":
    ensure  => link,
    target  => "/opt/apache-tomcat-${tomcat_version}/extras/tomcat-juli-adapters.jar",
    require => Common::Archive::Download["tomcat-juli-adapters.jar"],
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
        require => Common::Archive["apache-tomcat-${tomcat_version}"],
        mode => "755",
      }
    }
  }
}
