/*

== Class: tomcat

Base class from which others inherit. It shouldn't be necessary to include it
directly.

Class variables:
- *$log4j_conffile*: location of an alternate log4j.properties file. Default is
  puppet:///tomcat/conf/log4j.rolling.properties

*/
class tomcat {

  user{"tomcat":
    ensure => present,
  }

  case $operatingsystem {
    RedHat: {
      package { ["log4j", "jakarta-commons-logging"]: ensure => present }
    }
    Debian,Ubuntu: {
      package { ["liblog4j1.2-java", "libcommons-logging-java"]: ensure => present }
    }
  }

  file { "commons-logging.jar":
    path   => undef, # overrided in subclasses
    ensure => link,
    target => "/usr/share/java/commons-logging.jar",
  }

  file { "log4j.jar":
    path   => undef, # overrided in subclasses
    ensure => link,
    target => $operatingsystem ? {
      /Debian|Ubuntu/ => "/usr/share/java/log4j-1.2.jar",
      RedHat => "/usr/share/java/log4j.jar",
    },
  }

  file { "log4j.properties":
    path   => undef, # overrided in subclasses
    source => $log4j_conffile ? {
      default => $log4j_conffile,
      ""      => "puppet:///tomcat/conf/log4j.rolling.properties",
    },
  }

  file { "/var/log/tomcat":
    ensure => directory,
    owner  => "tomcat",
    group  => "tomcat",
  }

}
