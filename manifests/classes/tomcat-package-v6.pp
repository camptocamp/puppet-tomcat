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

}
