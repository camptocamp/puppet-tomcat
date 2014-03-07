define tomcat::resource(
  $server      = regsubst($name, '^([^:]+):[^:]+$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^([^:]+):[^:]+$', '\1'),
  },
  $resource    = regsubst($name, '^[^:]+:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:([^:]+)$', '\1'),
  },
  $auth        = undef,
  $description = undef,
  $factory     = undef,
  $type        = undef,
  $pathname    = undef,
) {
  validate_string($server)
  validate_string($resource)

  $_auth = $auth ? {
    undef   => '',
    default => " auth=\"${auth}\"",
  }
  $_description = $description ? {
    undef   => '',
    default => "\n              description=\"${description}\"",
  }
  $_factory = $factory ? {
    undef   => '',
    default => "\n              factory=\"${factory}\"",
  }
  $_pathname = $pathname ? {
    undef   => '',
    default => "\n              pathname=\"${pathname}\"",
  }
  $_type = $type ? {
    undef   => '',
    default => "\n              type=\"${type}\"",
  }
  concat_fragment { "server.xml_${server}_globalnamingresources+02_${resource}":
    content => "    <Resource name=\"${resource}\"${_auth}${_type}${_description}${_factory}${_pathname} />",
  }
}
