class tomcat::administration {

  group { "tomcat-admin":
    ensure => present,
  }

  common::concatfilepart { "sudoers.tomcat":
    ensure => present,
    file => "/etc/sudoers",
    content => "
# This part comes from modules/tomcat/manifests/classes/administration.pp
%tomcat-admin ALL=(root) /etc/init.d/tomcat-*
%tomcat-admin ALL=(root) /bin/su tomcat, /bin/su - tomcat
",
    require => Group["tomcat-admin"],
  }


}
