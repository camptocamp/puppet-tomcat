class tomcat::params {
  case $::osfamily {
    'Debian': {
      if $::operatingsystem == 'Debian' {
        if versioncmp($::operatingsystemmajrelease, '8') < 0 {
          $version = '6'
          $systemd = false
        } else {
          $version = '8'
          $systemd = true
        }
      } elsif $::operatingsystem == 'Ubuntu' {
        $version = '7'
        $systemd = false
      }
    }

    'RedHat': {
      case $::operatingsystemmajrelease {
        '5': {
          $version = '5'
          $systemd = false
          $commons_logging_package = 'jakarta-commons-logging'
        }

        '6': {
          $version = '6'
          $systemd = false
          $commons_logging_package = 'jakarta-commons-logging'
        }

        '7': {
          $version = '7'
          $systemd = true
          $commons_logging_package = 'apache-commons-logging'
        }

        default: {
          fail "Unsupported release ${::operatingsystemmajrelease}"
        }
      }
    }

    default: {
      fail "Unsupported OS family '${::osfamily}'"
    }
  }

  $instance_basedir = '/srv/tomcat'
  $sources_src = 'http://archive.apache.org/dist/tomcat/'

}
