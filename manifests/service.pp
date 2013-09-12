class tomcat::service {
  service {"tomcat${tomcat::version}":
    ensure => stopped,
    enable => false,
  } ->
  file {"/etc/init.d/tomcat${tomcat::version}":
    ensure => file,
    mode   => '0644',
  }
}
