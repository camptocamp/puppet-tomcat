define tomcat::listener(
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
  $ssl_engine = undef,
) {
  validate_string($server)
  validate_string($class_name)

  $_ssl_engine = $ssl_engine ? {
    undef   => '',
    default => "SSLEngine=\"${ssl_engine}\" ",
  }

  if $engine == undef {
    concat_fragment { "server.xml_${server}+02_${class_name}":
      content => "  <Listener className=\"${class_name}\" ${_ssl_engine}/>",
    }
  } else {
    validate_string($engine)
    if $host == undef {
      concat_fragment { "server.xml_${server}_service_${service}_engine+02_${class_name}":
        content => "      <Listener className=\"${class_name}\" ${_ssl_engine}/>",
      }
    } else {
      validate_string($host)
      if $context == undef {
        concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}+02_${class_name}":
          content => "        <Listener className=\"${class_name}\" ${_ssl_engine}/>",
        }
      } else {
        validate_string($context)
        concat_fragment { "server.xml_${server}_service_${service}_engine_host_${host}_context_${context}+02_${class_name}":
          content => "          <Listener className=\"${class_name}\" ${_ssl_engine}/>",
        }
      }
    }
  }

}
