define tomcat::instance::service {

  $ensure = getparam(Tomcat::Instance[$title], 'ensure') ? {
    present   => 'running',
    running   => 'running',
    stopped   => 'stopped',
    installed => undef,
    absent    => 'stopped',
  }

  $enable = getparam(Tomcat::Instance[$title], 'ensure') ? {
    present   => true,
    running   => true,
    stopped   => false,
    installed => false,
    absent    => false,
  }

  service {"tomcat-${name}":
    ensure  => $ensure,
    enable  => $enable,
    # FIXME: is this still require ?
    pattern => "-Dcatalina.base=${tomcat::instance_basedir}/${name}",
  }
}
