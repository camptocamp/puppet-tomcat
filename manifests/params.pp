class tomcat::params {
  $version = $::osfamily? {
    Debian => 6,
    RedHat => $::lsbdistmajrelease,
  }

  $uid = undef
  $gid = undef

  # UGLY hack for juli/logging [debian only for what I can see]
  $src_version = $version? {
    5 => '5.5.27',
    6 => '6.0.26',
    7 => '7.0.42',
  }

  $home = $::osfamily? {
    Debian => "/usr/share/tomcat${version}",
    RedHat => "/var/lib/tomcat${version}",
  }

  $instance_basedir = '/srv/tomcat'
  $sources_src = 'http://archive.apache.org/dist/tomcat/'
}
