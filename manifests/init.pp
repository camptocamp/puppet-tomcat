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

  $src_version = $version? {
    5 => '5.5.27',
    6 => '6.0.26',
    7 => '7.0.42',
  }

  $home = $sources ? {
    true  => "/opt/apache-tomcat-${src_version}",
    false => $::osfamily? {
      Debian => "/usr/share/tomcat${version}",
      RedHat => "/var/lib/tomcat${version}",
    }
  }

  create_resources('tomcat::ulimit', $ulimits)

  class {'tomcat::install': } ->
  class {'tomcat::user': } ->
  class {'tomcat::service': } ->
  Class['tomcat']
}
