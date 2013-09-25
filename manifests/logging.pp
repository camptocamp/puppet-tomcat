# == Class: tomcat::logging
#
# Links logging libraries in tomcat installation directory
#
# Attributes:
# - *conffile*:    configuration file for log4j
#
# This class is just there to avoid code duplication. It probably
# doesn't make any sense to include it directly.
#
class tomcat::logging (
  $conffile    = "puppet:///modules/${module_name}/conf/log4j.rolling.properties",
) {

  $package = $::osfamily? {
    Debian => ['liblog4j1.2-java', 'libcommons-logging-java'],
    RedHat => ['log4j', 'jakarta-commons-logging'],
  }

  package {$package:
    ensure => present,
  }

  $base_path = $tomcat::version ? {
    '5'     => "${tomcat::home}/common/lib",
    default => "${tomcat::home}/lib",
  }

  $log4j = $::osfamily? {
    Debian => '/usr/share/java/log4j-1.2.jar',
    RedHat => '/usr/share/java/log4j.jar',
  }

  file {'/var/log/tomcat':
    ensure => directory,
    owner  => 'tomcat',
    group  => 'tomcat',
  }

  file {'commons-logging.jar':
    ensure  => link,
    path    => "${base_path}/commons-logging.jar",
    target  => '/usr/share/java/commons-logging.jar',
    require => Package[$package],
  }

  file {'log4j.jar':
    ensure  => link,
    path    => "${base_path}/log4j.jar",
    target  => $log4j,
    require => Package[$package],
  }

  file {'log4j.properties':
    path    => "${base_path}/log4j.properties",
    source  => $conffile,
    require => Package[$package],
  }

}
