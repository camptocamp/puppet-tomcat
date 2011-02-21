/*

== Class: tomcat::redhat

Installs tomcat on Redhat using your systems package manager.

Requires:
- java to be previously installed

Tested on:
- Redhat 5.6 (Tikanga)
- Redhat 6.0 (Santiago)

Usage:
  include tomcat::redhat

*/
class tomcat::redhat inherits tomcat::package {

  package { [
    "log4j", 
    "jakarta-commons-logging"
    ]: ensure => present 
  }

  case $lsbdistcodename {

    Tikanga: {
      $tomcat = "tomcat5"
 
      file {"commons-logging.jar": 
        ensure => link,
        path   => "/var/lib/tomcat5/common/lib/commons-logging.jar",
      }
     
      file {"/usr/share/tomcat5/bin/catalina.sh":
        ensure => link,
        target => "/usr/bin/dtomcat5",
      }
    }

    Santiago: {
      $tomcat = "tomcat6"

      # replaced the /usr/sbin/tomcat6 included script with setclasspath.sh and catalina.sh
      file {"/usr/share/${tomcat}/bin/setclasspath.sh":
        ensure => present,
        owner  => root,
        group  => root,
        mode   => 755,
        source => "puppet:///tomcat/setclasspath.sh-6.0.24" ,
        require => [ Package["tomcat"], File["/usr/share/${tomcat}"] ],
      }

      file {"/usr/share/${tomcat}/bin/catalina.sh":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 755,
        source  => "puppet:///tomcat/catalina.sh-6.0.24",
        require => File["/usr/share/${tomcat}/bin/setclasspath.sh"],
      }

    }
  }

  Package["tomcat"] { name => $tomcat }
  User["tomcat"] { require => Package[$tomcat] }
  
  file {"/usr/share/${tomcat}":
    require => Package["tomcat"],
  }

  Service["tomcat"] {
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => "-Dcatalina.base=/usr/share/${tomcat}",
  } 

}
