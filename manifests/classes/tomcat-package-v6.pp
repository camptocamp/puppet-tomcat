/*

== Class: tomcat::package::v6

Installs tomcat 6.0.X using your systems package manager.

Class variables:
- *$log4j_conffile*: see tomcat

Requires:
- java to be previously installed

Tested on:
- Debian Lenny (using backported packages from Squeeze)

Usage:
  include tomcat::package::v6

*/
class tomcat::package::v6 inherits tomcat::package {

  case $operatingsystem {
    RedHat: {
      package { ["log4j", "jakarta-commons-logging"]: ensure => present }
    }
    Debian,Ubuntu: {
      package { ["liblog4j1.2-java", "libcommons-logging-java"]: ensure => present }
    }
  } 

  $tomcat = $operatingsystem ? {
    #TODO: RedHat => "tomcat6",
    Debian => "tomcat6",
    Ubuntu => "tomcat6",
  }

  $tomcat_home = "/usr/share/tomcat6"

  # Workaround while tomcat-juli.jar and tomcat-juli-adapters.jar aren't
  # included in tomcat6-* packages.
  include tomcat::juli

  Package["tomcat"] {
    name   => $tomcat,
    before => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  Service["tomcat"] {
    name    => $tomcat,
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => $operatingsystem ? {
      Debian => "-Dcatalina.base=/var/lib/tomcat",
      Ubuntu => "-Dcatalina.base=/var/lib/tomcat",
      RedHat => "-Dcatalina.base=/usr/share/tomcat",
    },
  }

  File["/etc/init.d/tomcat"] {
    path => "/etc/init.d/${tomcat}",
  }

  file { $tomcat_home:
    ensure  => directory,
    require => Package["tomcat"],
  }

  file {"commons-logging.jar":
    path => $operatingsystem ? {
      #RedHat => TODO,
      Debian  => "/usr/share/tomcat6/lib/commons-logging.jar",
    },
    ensure => link,
    target => "/usr/share/java/commons-logging.jar",
  }

  file {"log4j.jar":
    path => $operatingsystem ? {
      #RedHat => TODO,
      Debian  => "/usr/share/tomcat6/lib/log4j.jar",
    },
    ensure => link,
    target => $operatingsystem ? {
      /Debian|Ubuntu/ => "/usr/share/java/log4j-1.2.jar",
      RedHat          => "/usr/share/java/log4j.jar",
    },
  }

  file {"log4j.properties":
    path => $operatingsystem ? {
      #RedHat => TODO,
      Debian  => "/usr/share/tomcat6/lib/log4j.properties",
    },
    source => $log4j_conffile ? {
      default => $log4j_conffile,
      ""      => "puppet:///tomcat/conf/log4j.rolling.properties",
    },
  }

}
