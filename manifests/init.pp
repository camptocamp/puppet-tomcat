class tomcat (
  $version          = $tomcat::params::version,
  $sources          = false,
  $sources_src      = $tomcat::params::sources_src,
  $instance_basedir = $tomcat::params::instance_basedir,
  $tomcat_uid       = $tomcat::params::uid,
  $tomcat_gid       = $tomcat::params::gid,
  $ulimits          = {},
) inherits tomcat::params {

  validate_re($version, '^[5-7]$')
  validate_bool($sources)
  validate_absolute_path($instance_basedir)
  validate_hash($ulimits)

  if $sources {
    $type = 'sources'
  } else {
    $type = 'package'
  }

  create_resources('tomcat::ulimit', $ulimits)
  class {'tomcat::install': } ->
  class {'tomcat::user': } ->
  class {'tomcat::service': } ->
  Class['tomcat']
}
