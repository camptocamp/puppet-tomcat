/*

== Class: tomcat::package

Common stuff shared between tomcat::package::* classes. It shouldn't be
necessary to include it directly.

*/
class tomcat::package inherits tomcat::base {

  package { 'tomcat':
    ensure => present,
  }

  service { 'tomcat':
    ensure    => stopped,
    enable    => false,
    hasstatus => false,
    require   => Package['tomcat'],
  }

  file { '/usr/share/tomcat':
    ensure => directory,
  }

  # prevent default init-script from being accidentaly used
  file { '/etc/init.d/tomcat':
    mode    => '0644',
    require => [Service['tomcat'], Package['tomcat']],
  }

}
