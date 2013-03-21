/*

== Class: tomcat::base

Base class from which others inherit. It shouldn't be necessary to include it
directly.

Class variables:
- *$log4j_conffile*: location of an alternate log4j.properties file. Default is
  puppet:///modules/tomcat/conf/log4j.rolling.properties

*/
class tomcat::base {

  user{"tomcat":
    ensure => present,
    uid    => $tomcat_uid? {
      ''      => undef,
      default => $tomcat_uid,
    },
    groups => $tomcat_groups? {
      ''      => undef,
      default => $tomcat_groups,
    },
    system => true,
  }

  file { "/var/log/tomcat":
    ensure => directory,
    owner  => "tomcat",
    group  => "tomcat",
  }

}
