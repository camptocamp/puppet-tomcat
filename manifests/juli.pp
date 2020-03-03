# == Class: tomcat::juli
class tomcat::juli {

  case $::osfamily {
    'Debian': {
      include ::tomcat::juli::debian
    }
    default: { }
  }
}
