/*

== Class: tomcat::administration

Creates a "tomcat-admin" group and use sudo to allows members of this group
to:
- su to the tomcat user (which allows to kill java, remove lockfiles, etc)
- restart tomcat instances.

Requires:
- definition sudo::directive from module camptocamp/puppet-sudo

Warning: will overwrite /etc/sudoers !

*/
class tomcat::administration {

  group { 'tomcat-admin':
    ensure => present,
    system => true,
  }

  sudo::directive { 'tomcat-administration':
    ensure  => present,
    content => template('tomcat/sudoers.tomcat.erb'),
    require => Group['tomcat-admin'],
  }

}
