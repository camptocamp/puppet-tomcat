# == Class: tomcat::install
#
# install tomcat and logging stuff
#
class tomcat::install {

  $package_name = $::osfamily ? {
    'redhat' => $::operatingsystemmajrelease ? {
      '7'     => 'tomcat',
      default => "tomcat${tomcat::version}",
    },
    'debian' => "tomcat${tomcat::version}",
  }

  if !$tomcat::sources {
    package {'tomcat':
      ensure => present,
      name   => $package_name,
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
