/*

== Class: tomcat::package::v6

Installs tomcat 6.0.X using your systems package manager.

Class variables:
- *$log4j_conffile*: see tomcat

Requires:
- java to be previously installed

Tested on:
- Debian Lenny (using backported packages from Squeeze)

Usage:
  include tomcat::package::v6

*/
class tomcat::package::v6 inherits tomcat {

  $tomcat = $operatingsystem ? {
    #TODO: RedHat => "tomcat6",
    Debian => "tomcat6",
    Ubuntu => "tomcat6",
  }

  include tomcat::package

  File["commons-logging.jar"] {
    path => $operatingsystem ? {
      #RedHat => TODO,
      Debian  => "/usr/share/tomcat6/lib/commons-logging.jar",
    },
  }

  File["log4j.jar"] {
    path => $operatingsystem ? {
      #RedHat => TODO,
      Debian  => "/usr/share/tomcat6/lib/log4j.jar",
    },
  }

  File["log4j.properties"] {
    path => $operatingsystem ? {
      #RedHat => TODO,
      Debian  => "/usr/share/tomcat6/lib/log4j.properties",
    },
  }

  # Workaround while tomcat-juli.jar and tomcat-juli-adapters.jar aren't
  # included in tomcat6-* packages. Most of what follows is a duplicate of
  # tomcat::v6 and should be removed ASAP.

  if ( ! $tomcat_version ) {
    $tomcat_version = "6.0.20"
  }

  if ( ! $mirror ) {
    $mirror = "http://mirror.switch.ch/mirror/apache/dist/tomcat/"
  }

  $baseurl = "${mirror}/tomcat-6/v${tomcat_version}/bin/"

  file { "/usr/share/tomcat6/extras/":
    ensure  => directory,
    require => Class["tomcat::package"],
  }

  exec { "fetch tomcat-juli.jar":
    command => "curl -o /usr/share/tomcat6/extras/tomcat-juli.jar ${baseurl}/extras/tomcat-juli.jar",
    creates => "/usr/share/tomcat6/extras/tomcat-juli.jar",
    require => File["/usr/share/tomcat6/extras/"],
  }

  exec { "fetch tomcat-juli-adapters.jar":
    command => "curl -o /usr/share/tomcat6/extras/tomcat-juli-adapters.jar ${baseurl}/extras/tomcat-juli-adapters.jar",
    creates => "/usr/share/tomcat6/extras/tomcat-juli-adapters.jar",
    require => File["/usr/share/tomcat6/extras/"],
  }

  file { "/usr/share/tomcat6/bin/tomcat-juli.jar":
    ensure  => link,
    target  => "/usr/share/tomcat6/extras/tomcat-juli.jar",
    require => Exec["fetch tomcat-juli.jar"],
  }

  file { "/usr/share/tomcat6/lib/tomcat-juli-adapters.jar":
    ensure  => link,
    target  => "/usr/share/tomcat6/extras/tomcat-juli-adapters.jar",
    require => Exec["fetch tomcat-juli-adapters.jar"],
  }

}
