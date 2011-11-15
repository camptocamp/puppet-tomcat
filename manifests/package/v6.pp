/*

== Class: tomcat::package::v6

Deprecated: include "tomcat" instead!

*/
class tomcat::package::v6 {
  notify {"class $name is deprecated, class 'tomcat' is automatically included for backwards compatibility":}
  include tomcat
}
