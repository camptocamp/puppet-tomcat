/*

== Class: tomcat::package

Common stuff shared between tomcat::package::* classes. It shouldn't be
necessary to include it directly.

*/
class tomcat::package {

  package { "tomcat":
    ensure => present,
    name   => $tomcat,
    before => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  service { $tomcat:
    ensure  => stopped,
    enable  => false,
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => $operatingsystem ? {
      Debian => "-Dcatalina.base=/var/lib/tomcat",
      Ubuntu => "-Dcatalina.base=/var/lib/tomcat",
      RedHat => "-Dcatalina.base=/usr/share/tomcat",
    },
    require => Package["tomcat"],
  }

  # prevent default init-script from being accidentaly used
  file { "/etc/init.d/${tomcat}":
    mode    => 0644,
    require => [Service[$tomcat], Package[$tomcat]],
  }

}
