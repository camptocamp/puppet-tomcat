class tomcat::user {
  user {'tomcat':
    ensure => present,
    uid    => $::tomcat::tomcat_uid,
    gid    => $::tomcat::tomcat_gid,
    system => true,
    home   => $::tomcat::instance_basedir,
  }
}
