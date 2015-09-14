# == Class: tomcat::logging
#
# Links logging libraries in tomcat installation directory
#
# This class must not be included directly. It is automatically included
# by the tomcat module.
#
class tomcat::logging {

  $conffile = "puppet:///modules/${module_name}/conf/log4j.rolling.properties"

  $base_path = $::tomcat::version ? {
    '5'     => "${::tomcat::home}/common/lib",
    default => "${::tomcat::home}/lib",
  }

  $log4j_packages = $::osfamily? {
    'Debian' => ['liblog4j1.2-java', 'libcommons-logging-java'],
    'RedHat' => ['log4j', $::tomcat::params::commons_logging_package],
  }

  package {$log4j_packages:
    ensure => present,
  }

  $log4j = $::osfamily? {
    'Debian' => '/usr/share/java/log4j-1.2.jar',
    'RedHat' => '/usr/share/java/log4j.jar',
  }

  # The source class need (and define) this directory before logging
  if $::tomcat::sources == false {
    file {$base_path:
      ensure => directory,
    }
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
    require => Package[$log4j_packages],
  }

  file {'log4j.jar':
    ensure  => link,
    path    => "${base_path}/log4j.jar",
    target  => $log4j,
    require => Package[$log4j_packages],
  }

  file {'log4j.properties':
    path    => "${base_path}/log4j.properties",
    source  => $conffile,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$log4j_packages],
  }

}
