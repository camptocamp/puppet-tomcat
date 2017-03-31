# == Class: tomcat::install::redhat
#
# Some hacks needed on redhat...
#
class tomcat::install::redhat {

  case $::operatingsystemmajrelease {
    '5': {
      file {'/usr/share/tomcat5/bin/catalina.sh':
        ensure  => link,
        target  => "/usr/bin/dtomcat${tomcat::version}",
        require => Package['tomcat'],
      }
    }

    '6': {
      file {"/usr/share/tomcat${tomcat::version}/bin/setclasspath.sh":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0755',
        content => file(sprintf('%s/files/setclasspath.sh-6.0.24', get_module_path($module_name))),
        require => Package['tomcat'],
      }
      -> file {"/usr/share/tomcat${tomcat::version}/bin/catalina.sh":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0755',
        content => file(sprintf('%s/files/catalina.sh-6.0.24', get_module_path($module_name))),
      }
    }
    '7': {}
    default: {
      fail "Don't know what to do for ${::operatingsystem}/${::operatingsystemmajrelease}"
    }
  }
}
