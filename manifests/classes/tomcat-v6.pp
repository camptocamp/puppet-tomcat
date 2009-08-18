class tomcat::v6 inherits tomcat {

  if ( ! $tomcat_version ) {
    $tomcat_version = "6.0.20"
  }

  if ( ! $mirror ) {
    $mirror = "http://mirror.switch.ch/mirror/apache/dist/tomcat/"
  }

  $url = "${mirror}/tomcat-6/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"

  common::archive::tar-gz{"/opt/apache-tomcat-${tomcat_version}/.installed":
    source => $url,
    target => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure => link,
    target => "/opt/apache-tomcat-${tomcat_version}",
    require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
  }

  # Workarounds
  case $tomcat_version {
    "6.0.18": {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"/opt/apache-tomcat-${tomcat_version}/bin/catalina.sh":
        ensure  => present,
        source  => "puppet:///tomcat/catalina.sh-6.0.18",
        require => Common::Archive::Tar-gz["/opt/apache-tomcat-${tomcat_version}/.installed"],
        mode => "755",
      }
    }
  }
}
