#
#
# == Class: tomcat
#
# Installs tomcat using the default version providing by distributions.
#
# Example usage:
#
#  include tomcat
#
#
class tomcat {
  case $::osfamily {
    RedHat: { include tomcat::redhat }
    Debian: { include tomcat::debian }
    default: { fail "Unsupported OS family ${::osfamily}" }
  }
}
