#
#
#== Class: tomcat::v5-5
#
#Deprecated: include "tomcat::source" instead!
#
#
class tomcat::v5-5 {
  include tomcat::params
  $tomcat_version = $tomcat::params::default_source_release_v55
  notify {"class $name is deprecated, class 'tomcat' is automatically included for backwards compatibility":}
  include tomcat::source
}
