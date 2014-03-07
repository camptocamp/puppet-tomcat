define tomcat::engine(
  $default_host = 'localhost',
  $hosts        = {},
  $realms       = {},
  $server  = regsubst($name, '^([^:]+):[^:]+:[^:]+$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^([^:]+):[^:]+:[^:]+$', '\1'),
  },
  $service = regsubst($name, '^[^:]+:([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:([^:]+):.*$', '\1'),
  },
  $engine  = regsubst($name, '^[^:]+:[^:]+:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:[^:]+:([^:]+)$', '\1'),
  },
) {
  concat_build { "server.xml_${server}_service_${service}_engine":
    parent_build => "server.xml_${server}_service_${service}",
    target       => "/var/lib/puppet/concat/fragments/server.xml_${server}_service_${service}/30",
  }
  concat_fragment { "server.xml_${server}_service_${service}_engine+01":
    content => "    <Engine name=\"${engine}\" defaultHost=\"${default_host}\">",
  }
  concat_fragment { "server.xml_${server}_service_${service}_engine+99":
    content => "    </Engine>",
  }
  create_resources(
    'tomcat::host',
    hash(
      zip(prefix(keys($hosts), "${server}:${service}:${engine}:"),
      values($hosts))
    )
  )
  create_resources(
    'tomcat::realm',
    hash(
      zip(prefix(keys($realms), "${server}:${service}:${engine}:"),
      values($realms))
    )
  )
}
