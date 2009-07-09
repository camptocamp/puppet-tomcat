class tomcat::package inherits tomcat {

  case $operatingsystem {

    RedHat: {
      package { "tomcat5": ensure => present }

      file { "/usr/share/tomcat5/bin/catalina.sh":
        ensure => link,
        target => "/usr/bin/dtomcat5",
      }

      # prevent default init-script from running
      service { "tomcat5":
        enable => false,
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
