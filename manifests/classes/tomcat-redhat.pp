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

  # avoid partial configuration on untested-redhat-release
  if $lsbdistcodename !~ /^(Tikanga|Santiago)$/ {
    fail "class ${name} not tested on ${operatingsystem}/${lsbdistcodename}"
  }

  package { [
    "log4j", 
    "jakarta-commons-logging"
    ]: ensure => present 
  }

  case $lsbdistcodename {

    Tikanga: {
      $tomcat = "tomcat5"
     
      file {"/usr/share/tomcat5/bin/catalina.sh":
        ensure  => link,
        target  => "/usr/bin/dtomcat5",
        require => Package["tomcat"],
      }

      file {"commons-logging.jar":
        path    => "/var/lib/tomcat5/common/lib/commons-logging.jar", 
        ensure  => link,
        target  => "/usr/share/java/commons-logging.jar",
      }

      file {"log4j.jar":
        path   => "/var/lib/tomcat5/common/lib/log4j.jar",
        ensure => link,
        target => "/usr/share/java/log4j.jar",
      }
  
      file {"log4j.properties":
        path   => "/var/lib/tomcat5/common/classes/log4j.properties",
        source => $log4j_conffile ? {
          default => $log4j_conffile,
          ""      => "puppet:///tomcat/conf/log4j.rolling.properties",
        },
      }

      Package["tomcat"] { 
        name   => $tomcat,
        before => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],  
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
      
      Package["tomcat"] { name => $tomcat }

    }
  }

  User["tomcat"] { 
    require => Package[$tomcat],
  }

  File["/usr/share/tomcat"] {
    path => "/usr/share/${tomcat}",
  }

  Service["tomcat"] {
    stop    => "/bin/sh /etc/init.d/${tomcat} stop",
    pattern => "-Dcatalina.base=/usr/share/${tomcat}",
  } 

  File["/etc/init.d/tomcat"] {
    path => "/etc/init.d/${tomcat}",
  }

}
