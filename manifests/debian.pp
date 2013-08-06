/*

== Class: tomcat::debian

Installs tomcat on Debian using your systems package manager.

Requires:
- java to be previously installed

Tested on:
- Debian 5 (lenny, using backported packages from squeeze)

Usage:
  include tomcat::debian

*/
class tomcat::debian inherits tomcat::package {

  # avoid partial configuration on untested-debian-releases
  if $::lsbdistcodename !~ /^(lenny|squeeze|precise|wheezy)$/ {
    fail "class ${name} not tested on ${::operatingsystem}/${::lsbdistcodename}"
  }

  $tomcat      = 'tomcat6'
  $tomcat_home = '/usr/share/tomcat6'

  # Workaround while tomcat-juli.jar and tomcat-juli-adapters.jar aren't
  # included in tomcat6-* packages.
  include tomcat::juli

  # link logging libraries from java
  include tomcat::logging

  Package['tomcat'] {
    name   => $tomcat,
    before => [File['commons-logging.jar'], File['log4j.jar'], File['log4j.properties']],
  }

  Service['tomcat'] {
    name    => $tomcat,
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => "-Dcatalina.base=/var/lib/${tomcat}",
  }

  File['/usr/share/tomcat'] {
    path => $tomcat_home,
  }

  File['/etc/init.d/tomcat'] {
    path => "/etc/init.d/${tomcat}",
  }

}
