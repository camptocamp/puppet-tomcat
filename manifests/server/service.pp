define tomcat::server::service(
  $enable = true,
  $start  = true,
) {
  $ensure = $start ? {
    true    => running,
    default => stopped,
  }

  service {"tomcat-${name}":
    ensure  => $ensure,
    enable  => $enable,
  }
}
