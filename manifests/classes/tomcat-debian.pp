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

  $tomcat = "tomcat6"

  # Workaround while tomcat-juli.jar and tomcat-juli-adapters.jar aren't
  # included in tomcat6-* packages.
  include tomcat::juli

  package {"tomcat":
    name => $tomcat,
    before => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  Service[$tomcat] {
    pattern => "-Dcatalina.base=/var/lib/${tomcat}",
  }

  file {"commons-logging.jar":
    path   => "/usr/share/tomcat6/lib/commons-logging.jar",
    ensure => link,
    target => "/usr/share/java/commons-logging.jar",
  }

  file {"log4j.jar":
    path => "/usr/share/tomcat6/lib/log4j.jar",
    ensure => link,
    target => "/usr/share/java/log4j-1.2.jar",
  }

  file {"log4j.properties":
    path   => "/usr/share/tomcat6/lib/log4j.properties",
    source => $log4j_conffile ? {
      default => $log4j_conffile,
      ""      => "puppet:///tomcat/conf/log4j.rolling.properties",
    },
  }

}
