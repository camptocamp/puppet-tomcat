class tomcat::install {

  include tomcat::params

  if !$tomcat::sources {
    package {"tomcat${tomcat::version}":
      ensure => present,
    } ->
    class {'::tomcat::juli':
      tomcat_home => $tomcat::params::home,
    } ->
    class {'::tomcat::logging':
      tomcat_home => $tomcat::params::home,
    }

    if $::osfamily == 'RedHat' {
      class {'::tomcat::install::redhat':
        tomcat_home => $tomcat::params::home,
      }
    }
  } else {
    class {'tomcat::source':
      version     => $tomcat::version,
      sources_src => $tomcat::sources_src,
    }
  }
}
