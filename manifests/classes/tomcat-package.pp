class tomcat::v5-5::package inherits tomcat {

  $tomcat = $operatingsystem ? {
    RedHat => "tomcat5",
    Debian => "tomcat5.5",
    Ubuntu => "tomcat5.5",
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


  case $operatingsystem {

    RedHat: {

      file { "/usr/share/tomcat5/bin/catalina.sh":
        ensure => link,
        target => "/usr/bin/dtomcat5",
      }

      User["tomcat"] {
        require => Package["tomcat5"],
      }
    }

    default: {
      err("operating system '${operatingsystem}' not defined.")
    }

  }

}
