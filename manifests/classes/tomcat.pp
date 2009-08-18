/*

== Class: tomcat

Base class from which others inherit. It shouldn't be necessary to include it
directly.

*/
class tomcat {

  user{"tomcat":
    ensure => present,
  }

  # TODO: nagios checks
}
