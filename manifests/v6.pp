/*

== Class: tomcat::v6

Deprecated: include "tomcat::source" instead!

*/
class tomcat::v6 {
  notify {"class $name is deprecated, class 'tomcat' is automatically included for backwards compatibility":}
  include tomcat::source
}
