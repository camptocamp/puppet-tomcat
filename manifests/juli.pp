class tomcat::juli (
  $tomcat_home = $tomcat::params::home
) inherits ::tomcat::params {

  validate_absolute_path($tomcat_home)

  case $::osfamily {
    Debian: {
      class {'::tomcat::juli::debian':
        tomcat_home => $tomcat_home,
      }
    }
    default: { }
  }
}
