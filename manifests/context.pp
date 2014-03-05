define tomcat::context(
  $path,
  $server     = regsubst($name, '^([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^([^:]+):.*$', '\1'),
  },
  $service    = regsubst($name, '^[^:]+:([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:([^:]+):.*$', '\1'),
  },
  $engine     = regsubst($name, '^[^:]+:[^:]+:([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:[^:]+:([^:]+):.*$', '\1'),
  },
  $host       = regsubst($name, '^[^:]+:[^:]+:[^:]+:([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:[^:]+:[^:]+:([^:]+):.*$', '\1'),
  },
  $context    = regsubst($name, '^.*:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^.*:([^:]+)$', '\1'),
  },
) {
  validate_string($server)
  validate_string($service)
  validate_string($engine)
  validate_string($host)
  validate_string($context)

  concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}+02_${context}":
    content => "        <Context path=\"${path}\" />",
  }
}
