define tomcat::instance::service(
  $ensure,
) {

  $_ensure = $ensure ? {
    'present'   => 'running',
    'running'   => 'running',
    'stopped'   => 'stopped',
    'installed' => undef,
    'absent'    => 'stopped',
  }

  $_enable = $ensure ? {
    'present'   => true,
    'running'   => true,
    'stopped'   => false,
    'installed' => false,
    'absent'    => false,
  }

  service {"tomcat-${name}":
    ensure  => $_ensure,
    enable  => $_enable,
    # FIXME: is this still require ?
    pattern => "-Dcatalina.base=${tomcat::instance_basedir}/${name}",
  }
}
