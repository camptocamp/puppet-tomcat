# == Class: tomcat::logging
#
# Links logging libraries in tomcat installation directory
#
# Attributes:
# - *tomcat_home*: path to tomcat installation directory.
# - *conffile*:    configuration file for log4j
# - *version*:     tomcat version.
#
# This class is just there to avoid code duplication. It probably
# doesn't make any sense to include it directly.
#
class tomcat::logging (
  $tomcat_home = $tomcat::params::home,
  $conffile    = "puppet:///modules/${module_name}/conf/log4j.rolling.properties",
  $version     = $tomcat::params::version,
) inherits ::tomcat::params {

  validate_absolute_path($tomcat_home)
  validate_re($version, '^[5-7]$')

  $package = $::osfamily? {
    Debian => ['liblog4j1.2-java', 'libcommons-logging-java'],
    RedHat => ['log4j', 'jakarta-commons-logging'],
  }

  package {$package:
    ensure => present,
  }

  $base_path = $version? {
    '5'     => "${tomcat_home}/common/lib",
    default => "${tomcat_home}/lib",
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
