class tomcat::package {

  package { "tomcat":
    ensure => present,
    name   => $tomcat,
  }

  # prevent default init-script from being used
  service { $tomcat:
    enable  => false,
    require => Package["tomcat"],
  }

  file { "/etc/init.d/${tomcat}":
    ensure => absent,
    require => Service[$tomcat],
  }

}
