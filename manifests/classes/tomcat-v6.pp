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
- Ubuntu Lucid

Parameters:
  $tomcat_version: The tomcat version you wish to install. Defaults to $tomcat::params::default_source_release
  $mirror: URL of the closest tomcat mirror. Defaults to $tomcat::params::mirror

Usage:
  $tomcat_version = "6.0.18"
  include tomcat::v6

*/
class tomcat::v6 inherits tomcat::base {

  case $operatingsystem {
    RedHat: {
      package { ["log4j", "jakarta-commons-logging"]: ensure => present }
    }
    Debian,Ubuntu: {
      package { ["liblog4j1.2-java", "libcommons-logging-java"]: ensure => present }
    }
  }

  include tomcat::params
  
  if ( ! $tomcat_version ) {
    $tomcat_version = "${tomcat::params::default_source_release}"
  }

  if ( ! $mirror ) {
    $mirror = "${tomcat::params::mirror}"
  }

  $tomcat_home = "/opt/apache-tomcat-${tomcat_version}"

  # install extra tomcat juli adapters, used to configure logging.
  include tomcat::juli

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
    target => $tomcat_home,
    require => Common::Archive["apache-tomcat-${tomcat_version}"],
    before  => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  file { $tomcat_home:
    ensure  => directory,
    require => Common::Archive["apache-tomcat-${tomcat_version}"],
  }

  file {"commons-logging.jar":
    path   => "/opt/apache-tomcat/lib/commons-logging.jar",
    ensure => link,
    target => "/usr/share/java/commons-logging.jar",
  }

  file {"log4j.jar":
    path   => "/opt/apache-tomcat/lib/log4j.jar",
    ensure => link,
    target => $operatingsystem ? {
      /Debian|Ubuntu/ => "/usr/share/java/log4j-1.2.jar",
      RedHat          => "/usr/share/java/log4j.jar",
    },
  }

  file {"log4j.properties":
    path   => "/opt/apache-tomcat/lib/log4j.properties",
    source => $log4j_conffile ? {
      default => $log4j_conffile,
      ""      => "puppet:///tomcat/conf/log4j.rolling.properties",
    },
  }

  # Workarounds
  case $tomcat_version {
    "6.0.18": {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"${tomcat_home}/bin/catalina.sh":
        ensure  => present,
        source  => "puppet:///tomcat/catalina.sh-6.0.18",
        require => Common::Archive["apache-tomcat-${tomcat_version}"],
        mode => "755",
      }
    }
  }
}
