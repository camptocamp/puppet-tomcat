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

  $service_name = $::osfamily ? {
    'RedHat' => $::operatingsystemmajrelease ? {
      '7'     => 'tomcat',
      default => "tomcat${tomcat::version}",
    },
    'Debian' => "tomcat${tomcat::version}",
  }

  if !$tomcat::sources {
    package {'tomcat':
      ensure => present,
      name   => $package_name,
    }

    if $::osfamily != 'RedHat' or $::operatingsystemmajrelease != 7 {
      Package['tomcat'] ->
      class {'::tomcat::juli': } ->
      class {'::tomcat::logging': }

      if $::osfamily == 'RedHat' {
        class {'::tomcat::install::redhat': }
      }

      file {"/etc/init.d/tomcat${tomcat::version}":
        ensure  => file,
        mode    => '0644',
        require => Package['tomcat'],
        before  => Service['tomcat'],
      }
    }

    # Ensure default service is stopped
    service { 'tomcat':
      ensure => stopped,
      name   => $service_name,
      enable => false,
    }

  } else {
    class {'tomcat::source': }
  }
}
