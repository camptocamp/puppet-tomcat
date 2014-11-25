class tomcat::params {

  $version = $::osfamily? {
    'Debian' => $::operatingsystemmajrelease ? {
      /sid/   => '8',
      '8'     => '8',
      default => '6',
    },
    'RedHat' => $::operatingsystemmajrelease ? {
      '5' => '5',
      '6' => '6',
      '7' => '7',
    }
  }

  $instance_basedir = '/srv/tomcat'
  $sources_src = 'http://archive.apache.org/dist/tomcat/'

}
