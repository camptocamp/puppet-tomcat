class tomcat::v6 inherits tomcat {
  $tomcat_version = "6.0.18"
  $url = "http://mirror.switch.ch/mirror/apache/dist/tomcat/tomcat-6/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive::tar-gz{"/opt/apache-tomcat-${tomcat_version}/.installed":
    source => $url,
    target => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
  }

  # Workarounds
  case $tomcat_version {
    "6.0.18": {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"/opt/apache-tomcat-${tomcat_version}/bin/catalina.sh":
        ensure => present,
        source => "puppet:///tomcat/catalina.sh-6.0.18",
      }
    }
  }
}
