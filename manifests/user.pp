# == Class: tomcat::user
class tomcat::user {
  user {'tomcat':
    ensure => present,
    uid    => $::tomcat::tomcat_uid,
    gid    => $::tomcat::tomcat_gid,
    shell  => $::tomcat::tomcat_shell,
    system => true,
    home   => $::tomcat::instance_basedir,
  }
}
