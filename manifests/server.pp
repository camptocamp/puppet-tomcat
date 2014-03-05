define tomcat::server(
  $basedir   = "/srv/tomcat/${name}",
  $listeners = {},
  $port      = 8005,
  $resources = {},
  $services  = {},
  $setenv    = [],
  $shutdown  = 'SHUTDOWN',
) {
  validate_absolute_path($basedir)
  validate_hash($listeners)
  validate_re("${port}", '^[0-9]+$')
  validate_hash($resources)
  validate_hash($services)
  validate_string($shutdown)

  create_resources (
    'tomcat::listener',
    hash(zip(prefix(keys($listeners), "${name}:"), values($listeners)))
  )

  create_resources (
    'tomcat::resource',
    hash(zip(prefix(keys($resources), "${name}:"), values($resources)))
  )

  create_resources (
    'tomcat::service',
    hash(zip(prefix(keys($services), "${name}:"), values($services)))
  )

  tomcat::server::config { $name:
    basedir  => $basedir,
    port     => $port,
    setenv   => $setenv,
    shutdown => $shutdown,
  }
  ~>
  tomcat::server::service { $name:
  }

}
