/*

== Class: tomcat::source

Installs tomcat 5.5.X or 6.0.X using the compressed archive from your favorite tomcat
mirror. Files from the archive will be installed in /opt/apache-tomcat/.

Class variables:
- *$log4j_conffile*: see tomcat

Requires:
- java to be previously installed
- archive definition (from puppet camptocamp/puppet-archive module)
- Package["curl"]

Tested on:
- RHEL 5,6
- Debian Lenny/Squeeze
- Ubuntu Lucid

Usage:
  $tomcat_version = "6.0.18"
  include tomcat::source

*/
class tomcat::source inherits tomcat::base {

  include tomcat::params

  case $::osfamily {
    RedHat: {
      package { ['log4j', 'jakarta-commons-logging']:
        ensure => present,
      }
    }
    Debian: {
      package { ['liblog4j1.2-java', 'libcommons-logging-java']:
        ensure => present,
      }
    }
    default: {
      fail("Unsupported OS family ${::osfamily}")
    }
  }

  $tomcat_home = "/opt/apache-tomcat-${tomcat::params::version}"

  if $tomcat::params::maj_version == '6' {
    # install extra tomcat juli adapters, used to configure logging.
    include tomcat::juli
  }

  # link logging libraries from java
  include tomcat::logging

  $baseurl = $tomcat::params::maj_version ? {
    '5.5' => "${tomcat::params::mirror}/tomcat-5/v${tomcat::params::version}/bin",
    '6'   => "${tomcat::params::mirror}/tomcat-6/v${tomcat::params::version}/bin",
  }

  $tomcaturl = "${baseurl}/apache-tomcat-${tomcat::params::version}.tar.gz"

  archive{ "apache-tomcat-${tomcat::params::version}":
    url         => $tomcaturl,
    digest_url  => "${tomcaturl}.md5",
    digest_type => 'md5',
    target      => '/opt',
  }

  file { '/opt/apache-tomcat':
    ensure  => link,
    target  => $tomcat_home,
    require => Archive["apache-tomcat-${tomcat::params::version}"],
    before  => [File['commons-logging.jar'], File['log4j.jar'], File['log4j.properties']],
  }

  file { $tomcat_home:
    ensure  => directory,
    require => Archive["apache-tomcat-${tomcat::params::version}"],
  }

    # Workarounds
  case $tomcat::params::version {
    '6.0.18': {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"${tomcat_home}/bin/catalina.sh":
        ensure  => present,
        source  => 'puppet:///modules/tomcat/catalina.sh-6.0.18',
        require => Archive["apache-tomcat-${tomcat::params::version}"],
        mode    => '0755',
      }
    }
  }

}
