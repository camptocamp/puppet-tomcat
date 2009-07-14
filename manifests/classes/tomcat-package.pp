class tomcat::package inherits tomcat {

  case $operatingsystem {

    RedHat: {
      package { "tomcat5": ensure => present }

      file { "/usr/share/tomcat5/bin/catalina.sh":
        ensure => link,
        target => "/usr/bin/dtomcat5",
      }

      # prevent default init-script from being used
      service { "tomcat5":
        enable => false,
      }

      file { "/etc/init.d/tomcat5":
        ensure => absent,
        require => Service["tomcat5"],
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
