class tomcat::v5-5 inherits tomcat {
  $tomcat_version = "5.5.27"
  $url = "http://mirror.switch.ch/mirror/apache/dist/tomcat/tomcat-5/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive::tar-gz{"/opt/apache-tomcat-${tomcat_version}/.installed":
    source => $url,
    target => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
  }
}
