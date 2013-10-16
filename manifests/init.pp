class tomcat (
  $version          = $tomcat::params::version,
  $sources          = false,
  $sources_src      = $tomcat::params::sources_src,
  $instance_basedir = $tomcat::params::instance_basedir,
  $tomcat_uid       = undef,
  $tomcat_gid       = undef,
  $ulimits          = {},
) inherits ::tomcat::params {

  validate_re($version, '^[5-7]([\.0-9]+)?$')
  validate_bool($sources)
  validate_absolute_path($instance_basedir)
  validate_hash($ulimits)

  $type = $sources ? {
    true  => 'sources',
    false => 'package',
  }

  $temp_version_elements = split($version, '[.]')
  if (size($temp_version_elements) == 1) {
      $tomcat_version = $version
      $src_version = $version? {
          5       => '5.5.27',
          6       => '6.0.26',
          7       => '7.0.42',
      }
  } else {
      $tomcat_version = $temp_version_elements[0]
      $src_version = $version
  }

  $home = $sources ? {
    true  => "/opt/apache-tomcat-${src_version}",
    false => $::osfamily? {
      Debian => "/usr/share/tomcat${tomcat_version}",
      RedHat => "/var/lib/tomcat${tomcat_version}",
    }
  }

  create_resources('tomcat::ulimit', $ulimits)

  class {'tomcat::install': } ->
  class {'tomcat::user': } ->
  class {'tomcat::service': } ->
  Class['tomcat']
}
