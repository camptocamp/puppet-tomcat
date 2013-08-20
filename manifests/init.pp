/*

== Class: tomcat

Installs tomcat using the default version providing by distributions.

Example usage:

  include tomcat

*/
class tomcat (
  $home = $tomcat::params::home,
) inherits ::tomcat::params {
  case $::osfamily {
    RedHat: { include tomcat::redhat }
    Debian: { include tomcat::debian }
    default: { fail "Unsupported OS family ${::osfamily}" }
  }
}
