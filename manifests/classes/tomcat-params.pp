class tomcat::params {

  $default_source_release = "6.0.26"
  $default_source_release_v55 = "5.5.27"

  if $tomcat_mirror {
    $mirror = $tomcat_mirror
  } else {
    $mirror = "http://archive.apache.org/dist/tomcat/"
  }

  if defined(Class["Tomcat::v5-5"]) or defined(Class["Tomcat::v6"]) or defined(Class["Tomcat::source"]) {
    $type = "source"
    if ( ! $tomcat_version ) {
      $maj_version = "6"
      $version = $default_source_release
    } else {
      if versioncmp($tomcat_version, '6.0.0') >= 0 {
        $maj_version = "6"
      } else {
        if versioncmp($tomcat_version, '5.5.0') >= 0 {
          $maj_version = "5.5"
        } else {
          fail "only versions >= 5.5 or >= 6.0 are supported !"
        }
      }
    }
  } else {
    $type = "package"
    if $tomcat_version { notify {"\$tomcat_version is not useful when using distribution package!":} }
    $maj_version = $operatingsystem ? {
      "Debian" => $lsbdistcodename ? {
        /lenny|squeeze/ => "6",
      },
      "Redhat" => $lsbdistcodename ? {
        "Tikanga"  => "5.5",
        "Santiago" => "6",
      }
    }
  }

  if $tomcat_debug {
    notify{"type=${type},maj_version=${maj_version},version=${version}":}
  }

}
