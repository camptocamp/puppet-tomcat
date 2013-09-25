# == Class: tomcat::source
#
# Installs tomcat using the compressed archive from your favorite tomcat
# mirror. Files from the archive will be installed in /opt/apache-tomcat/.
#
# Class variables:
# - *$log4j_conffile*: see tomcat
#
# Requires:
# - java to be previously installed
# - archive definition (from puppet camptocamp/puppet-archive module)
# - Package["curl"]
#
# Tested on:
# - RHEL 5,6
# - Debian Lenny/Squeeze
# - Ubuntu Lucid
#
# Usage:
#   $tomcat_version = "6.0.18"
#   include tomcat::source
#
class tomcat::source (
  $version     = $tomcat::version,
  $sources_src = $tomcat::sources_src,
) {

  $tomcat_home = "/opt/apache-tomcat-${version}"

  if $version =~ /^6\./ {
    # install extra tomcat juli adapters, used to configure logging.
    class { '::tomcat::juli':
      tomcat_home => $tomcat_home,
    }
  }

  # link logging libraries from java
  class { '::tomcat::logging':
    tomcat_home => $tomcat_home,
  }

  $a_version = split($version, '[.]')
  $maj_version = $a_version[0]

  $baseurl = "${sources_src}/tomcat-${maj_version}/v${version}/bin"
  $tomcaturl = "${baseurl}/apache-tomcat-${version}.tar.gz"

  archive{ "apache-tomcat-${version}":
    url         => $tomcaturl,
    digest_url  => "${tomcaturl}.md5",
    digest_type => 'md5',
    target      => '/opt',
  }

  file { '/opt/apache-tomcat':
    ensure  => link,
    target  => $tomcat_home,
    require => Archive["apache-tomcat-${version}"],
    before  => Class['tomcat::logging'],
  }

  file { $tomcat_home:
    ensure  => directory,
    require => Archive["apache-tomcat-${version}"],
  }

  # Workarounds
  case $version {
    '6.0.18': {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"${tomcat_home}/bin/catalina.sh":
        ensure  => present,
        source  => 'puppet:///modules/tomcat/catalina.sh-6.0.18',
        require => Archive["apache-tomcat-${tomcat::version}"],
        mode    => '0755',
      }
    }
    default: {}
  }
}
