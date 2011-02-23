import "classes/*.pp"
import "definitions/*.pp"

/*

== Class: tomcat

Installs tomcat using the default version providing by distributions.

Example usage:

  include tomcat

*/
class tomcat {
  case $operatingsystem {
    RedHat       : { include tomcat::redhat }
    Debian,Ubuntu: { include tomcat::debian }
    default      : { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
