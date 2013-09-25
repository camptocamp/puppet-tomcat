# == Class: tomcat::install
#
# install tomcat and logging stuff
#
class tomcat::install {

  if !$tomcat::sources {
    package {"tomcat${tomcat::version}":
      ensure => present,
    } ->
    class {'::tomcat::juli': } ->
    class {'::tomcat::logging': }

    if $::osfamily == 'RedHat' {
      class {'::tomcat::install::redhat': }
    }
  } else {
    class {'tomcat::source': }
  }
}
