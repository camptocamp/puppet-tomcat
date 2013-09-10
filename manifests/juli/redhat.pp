class tomcat::juli::redhat {
  package {'log4j':
    ensure => present,
  }
}
