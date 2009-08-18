class tomcat::v6::package inherits tomcat {

  $tomcat = $operatingsystem ? {
    #TODO: RedHat => "tomcat6",
    Debian => "tomcat6",
    Ubuntu => "tomcat6",
  }

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
