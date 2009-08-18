/*

== Class: tomcat::administration

Creates a "tomcat-admin" group and use sudo to allows members of this group
to:
- su to the tomcat user (which allows to kill java, remove lockfiles, etc)
- restart tomcat instances.

Requires:
- management of /etc/sudoers with common::concatfilepart

Warning: will overwrite /etc/sudoers !

*/
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
