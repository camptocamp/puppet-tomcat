class tomcat::user {
  user {'tomcat':
    uid    => $tomcat::tomcat_uid,
    gid    => $tomcat::tomcat_gid,
    system => true,
  }
}
