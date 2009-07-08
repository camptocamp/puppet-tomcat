class tomcat {
  user{"tomcat":
    ensure => present,
  }

  # TODO: nagios checks
}
