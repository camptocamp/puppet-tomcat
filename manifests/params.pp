class tomcat::params {

  $default_source_release = '6.0.26'
  $default_source_release_v55 = '5.5.27'

  $instance_basedir = $tomcat_instance_basedir ? {
    ''      => '/srv/tomcat',
    default => $tomcat_instance_basedir,
  }

  if $tomcat_mirror {
    $mirror = $tomcat_mirror
  } else {
    $mirror = 'http://archive.apache.org/dist/tomcat/'
  }

  if defined(Class['Tomcat::source']) {
    $type = 'source'
    if ( ! $tomcat_version ) {
      $maj_version = '6'
      $version = $default_source_release
    } else {
      $version = $tomcat_version
      if versioncmp($tomcat_version, '6.0.0') >= 0 {
        $maj_version = '6'
      } else {
        if versioncmp($tomcat_version, '5.5.0') >= 0 {
          $maj_version = '5.5'
        } else {
          fail 'only versions >= 5.5 or >= 6.0 are supported !'
        }
      }
    }
  } else {
    $type = 'package'
    if $tomcat_version { notice('$tomcat_version is not useful when using distribution package!') }
    $maj_version = $::osfamily ? {
      'Debian' => $::lsbdistcodename ? {
        /lenny|squeeze/   => '6',
        'precise'         => '6',
      },
      'RedHat' => $::operatingsystemrelease ? {
        /^5.*/ => '5.5',
        /^6.*/ => '6',
      },
    }

    # it would be better to set the distribution tomcat-version!
    $version = $maj_version ? {
      '5.5' => $default_source_release_v55,
      '6'   => $default_source_release,
    }

  }

  if $tomcat_debug {
    notify{"type=${type},maj_version=${maj_version},version=${version}":}
  }

}
