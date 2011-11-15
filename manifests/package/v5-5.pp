/*

== Class: tomcat::package::v5-5

Deprecated: use simply "include tomcat" instead!

*/
class tomcat::package::v5-5 {
  notify {"class $name is deprecated, class 'tomcat' is automatically included for backwards compatibility":}
  include tomcat
}
