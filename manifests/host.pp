define tomcat::host(
  $app_base            = undef,
  $auto_deploy         = undef,
  $unpack_wars         = undef,
  $xml_validation      = undef,
  $xml_namespace_aware = undef,
  $contexts   = {},
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
  $host       = regsubst($name, '^.*:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^.*:([^:]+)$', '\1'),
  },
) {
  validate_hash($contexts)
  validate_string($server)
  validate_string($service)
  validate_string($engine)
  validate_string($host)

  $_app_base = $app_base ? {
    undef   => '',
    default => " appBase=\"${app_base}\"",
  }

  $_auto_deploy = $auto_deploy ? {
    undef   => '',
    default => " autoDeploy=\"${auto_deploy}\"",
  }

  $_unpack_wars = $unpack_wars ? {
    undef   => '',
    default => " unpackWARs=\"${unpack_wars}\"",
  }

  $_xml_validation = $xml_validation ? {
    undef   => '',
    default => " xmlValidation=\"${xml_validation}\"",
  }

  $_xml_namespace_aware = $xml_namespace_aware ? {
    undef   => '',
    default => " xmlNamespaceAware=\"${xml_namespace_aware}\"",
  }

  concat_build { "server.xml_${server}_service_${service}_engine_host_${host}":
    parent_build => "server.xml_${server}_service_${service}_engine",
    target       => "/var/lib/puppet/concat/fragments/server.xml_${server}_service_${service}_engine/20_${host}",
  }
  concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}+01":
    content => "      <Host name=\"${host}\"${_app_base}${_unpack_wars}${_autoDeploy}${_xml_validation}${_xml_namespace_aware}>",
  }
  concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}+99":
    content => "      </Host>",
  }

  create_resources(
    'tomcat::context',
    hash(zip(prefix(keys($contexts), "${server}:${service}:${engine}:${host}:"), values($contexts)))
  )
}
