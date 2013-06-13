/*

== Class: tomcat::logging

Links logging libraries in tomcat installation directory

Attributes:
- *tomcat_home*: path to tomcat installation directory.

This class is just there to avoid code duplication. It probably doesn't make
any sense to include it directly.

*/
class tomcat::logging {

  include tomcat::params

  if ( ! $tomcat_home ) {
    err('undefined mandatory attribute: $tomcat_home')
  }

  file {'commons-logging.jar':
    ensure => link,
    path   => $tomcat::params::maj_version ? {
      '5.5' => "${tomcat_home}/common/lib/commons-logging.jar",
      '6'   => "${tomcat_home}/lib/commons-logging.jar",
    },
    target => '/usr/share/java/commons-logging.jar',
  }

  file {'log4j.jar':
    ensure => link,
    path   => $tomcat::params::maj_version ? {
      '5.5' => "${tomcat_home}/common/lib/log4j.jar",
      '6'   => "${tomcat_home}/lib/log4j.jar",
    },
    target => $::osfamily ? {
      Debian => '/usr/share/java/log4j-1.2.jar',
      RedHat => '/usr/share/java/log4j.jar',
    },
  }

  file {'log4j.properties':
    path   => $tomcat::params::maj_version ? {
      '5.5' =>  "${tomcat_home}/common/lib/log4j.properties",
      '6'   =>  "${tomcat_home}/lib/log4j.properties",
    },
    source => $log4j_conffile ? {
      default => $log4j_conffile,
      ''      => 'puppet:///modules/tomcat/conf/log4j.rolling.properties',
    },
  }

}
