# == Class: tomcat::install::redhat
#
# Some hacks needed on redhat...
#
class tomcat::install::redhat {

  case $::operatingsystemmajrelease {
    5: {
      file {'/usr/share/tomcat5/bin/catalina.sh':
        ensure  => link,
        target  => "/usr/bin/dtomcat${tomcat::version}",
        require => Package["tomcat${tomcat::version}"],
      }
    }

    6: {
      file {"/usr/share/tomcat${tomcat::version}/bin/setclasspath.sh":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0755',
        source  => "puppet:///modules/${module_name}/setclasspath.sh-6.0.24",
        require => Package["tomcat${tomcat::version}"],
      } ->
      file {"/usr/share/tomcat${tomcat::version}/bin/catalina.sh":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0755',
        source  => "puppet:///modules/${module_name}/catalina.sh-6.0.24",
      }
    }
    default: {
      fail "Don't know what to do for ${::operatingsystem}/${::operatingsystemmajrelease}"
    }
  }
}
