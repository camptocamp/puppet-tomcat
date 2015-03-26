class tomcat::params {
  case $::osfamily {
    'Debian': {
      case $::operatingsystemmajrelease {
        /sid|8/: {
          $version = '8'
          $systemd = true
        }

        default: {
          $version = '6'
          $systemd = false
        }
      }
    }

    'RedHat': {
      case $::operatingsystemmajrelease {
        '5': {
          $version = '5'
          $systemd = false
        }

        '6': {
          $version = '6'
          $systemd = false
        }

        '7': {
          $version = '7'
          $systemd = true
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
