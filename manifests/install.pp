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
    # Ensure default service is stopped
    -> service { 'tomcat':
      ensure => stopped,
      name   => $service_name,
      enable => false,
    }

    if $::osfamily != 'RedHat' or versioncmp($::operatingsystemmajrelease, '7') != 0 {
      if versioncmp($::tomcat::version, '9') < 0 {
        class {'::tomcat::juli':
          require => Package['tomcat'],
        }
      }

      class {'::tomcat::logging':
        require => Package['tomcat'],
      }

      if $::osfamily == 'RedHat' {
        class {'::tomcat::install::redhat': }
      }
    }

  } else {
    class {'::tomcat::source': }
  }
}
