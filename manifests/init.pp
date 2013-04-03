#== Class: tomcat
#
#Installs tomcat using the default version providing by distributions.
#
#Example usage:
#
#  include tomcat
class tomcat(
  $jdk_pkg = undef,
) {
  case $::osfamily {
    RedHat: {
      validate_re($jdk_pkg, [undef, 'java-1.6.0-openjdk', 'java-1.7.0-openjdk'])
      include tomcat::redhat
    }
    Debian: {
      validate_re($jdk_pkg, [undef, 'openjdk-6-jdk', 'openjdk-7-jdk'])
      include tomcat::debian
    }
    default: { fail "Unsupported OS family ${::osfamily}" }
  }
}
