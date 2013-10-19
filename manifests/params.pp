class tomcat::params {

  $version = $::osfamily? {
    Debian => '6',
    RedHat => $::operatingsystemrelease ? {
      /^5.*/ => '5',
      /^6.*/ => '6',
    }
  }

  $instance_basedir = '/srv/tomcat'
  $sources_src = 'http://archive.apache.org/dist/tomcat/'

}
