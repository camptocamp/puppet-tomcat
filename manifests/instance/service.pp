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

  # Workaround to avoid puppet restarting tomcat
  # when the service is notified
  $_restart = $ensure ? {
    'installed' => '/bin/true',
    default     => undef,
  }

  service {"tomcat-${name}":
    ensure  => $_ensure,
    enable  => $_enable,
    restart => $_restart,
    # FIXME: is this still require ?
    pattern => "-Dcatalina.base=${tomcat::instance_basedir}/${name}",
  }
}
