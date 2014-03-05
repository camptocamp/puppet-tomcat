define tomcat::service(
  $connectors,
  $engine,
  $server  = regsubst($name, '^([^:]+):[^:]+$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^([^:]+):[^:]+$', '\1'),
  },
  $service = regsubst($name, '^[^:]+:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:([^:]+)$', '\1'),
  },
) {
  validate_hash($connectors)
  validate_hash($engine)
  validate_string($server)
  validate_string($service)

  concat_build { "server.xml_${server}_service_${service}":
    parent_build => "server.xml_${server}",
    target       => "/var/lib/puppet/concat/fragments/server.xml_${server}/10_${service}",
  }
  concat_fragment { "server.xml_${server}_service_${service}+01":
    content => "  <Service name=\"${service}\">",
  }
  concat_fragment { "server.xml_${server}_service_${service}+99":
    content => '  </Service>',
  }

  create_resources(
    'tomcat::connector',
    hash(zip(prefix(keys($connectors), "${server}:${service}:"), values($connectors))),
  )

  create_resources(
    'tomcat::engine',
    { "${server}:${service}:Catalina" => $engine, }
  )
}
