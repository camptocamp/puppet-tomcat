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

    # Moved from Class[tomcat::service] to here so that we can create a
    # tomcat::service definition.
    file {"/etc/init.d/tomcat${tomcat::version}":
      ensure  => file,
      mode    => '0644',
    }
    service {"tomcat${tomcat::version}":
      ensure => stopped,
      enable => false,
      before => File["/etc/init.d/tomcat${tomcat::version}"],
      require => Package["tomcat${tomcat::version}"],
    }
  } else {
    class {'tomcat::source': }
  }
}
