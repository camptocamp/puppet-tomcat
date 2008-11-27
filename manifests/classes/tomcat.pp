class tomcat {
  user{"tomcat":
    ensure => present,
  }

  group {"tomcat-users":
    ensure => present,
  }

  # TODO: sudo rules

  # TODO: nagios checks
}
