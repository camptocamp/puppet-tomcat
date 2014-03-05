define tomcat::realm(
  $resource_name,
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
  $context    = regsubst($name, '^[^:]+:[^:]+:[^:]+:[^:]+:([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:[^:]+:[^:]+:[^:]+:([^:]+):.*$', '\1'),
  },
  $class_name = regsubst($name, '^.*:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^.*:([^:]+)$', '\1'),
  },
) {
  validate_string($server)
  validate_string($service)
  validate_string($engine)
  validate_string($class_name)

  if $host == undef {
    concat_fragment { "server.xml_${server}_service_${service}_engine+10_${class_name}":
      content => "      <Realm className=\"${class_name}\" resourceName=\"${resource_name}\"/>",
    }
  } else {
    validate_string($host)
    if $context == undef {
      concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}+10_${class_name}":
        content => "        <Realm className=\"${class_name}\" resourceName=\"${resource_name}\"/>",
      }
    } else {
      validate_string($context)
      concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}_context_${context}+10_${class_name}":
        content => "        <Realm className=\"${class_name}\" resourceName=\"${resource_name}\"/>",
      }
    }
  }
}
