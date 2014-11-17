class tomcat::params {

  $version = $::osfamily? {
    Debian => $::operatingsystemmajrelease ? {
      /sid/   => '8',
      '8'     => '8',
      default => '6',
    },
    RedHat => $::operatingsystemmajrelease ? {
      '5' => '5',
      '6' => '6',
      '7' => '7',
    }
  }

  $instance_basedir = '/srv/tomcat'
  $sources_src = 'http://archive.apache.org/dist/tomcat/'

  if ($::osfamily == 'Debian' and ($::operatingsystemmajrelease =~ /sid/ or $::operatingsystemmajrelease >= 8)) or ($::osfamily == 'RedHat' and $::operatingsystemmajrelease >= 7) {
    $distro_way = true
  } else {
    $distro_way = false
  }

}
