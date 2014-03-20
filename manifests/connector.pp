# == Definition: tomcat::connector
#
# This definition will create a connector in a dedicated file
# included in server.xml with an XML entity inclusion.
# Have a look at http://tomcat.apache.org/tomcat-6.0-doc/config/http.html
# and http://tomcat.apache.org/tomcat-6.0-doc/config/ajp.html for more details.
#
# Parameters:
# - *name*: the filename prefix
# - *ensure*: define if this file is present or absent
# - *instance*: the name of the instance
# - *port*: (int) the tcp port of the server socket
# - *owner*: the owner of this file (useful if manage=false)
# - *group*: the group of this file (useful if manage=false)
# - *protocol*: the protocol to handle incoming traffic
# - *uri_encoding*: character encoding used to decode the URI bytes
# - *address*: the IP address on which the server must listen on
# - *connection_timeout*: (int) the number of milliseconds this connector
#   will wait, after accepting a connection
# - *redirect_port*: (int) automatic redirection if the request require
#   SSL transport
# - *scheme*: to identify the name of the protocol (default=http)
# - *executor*: the name of a thead pool shared between components
# - *manage*: only add this file/connector if it isn't already present
#
# Requires:
# - one of the tomcat classes which installs tomcat binaries.
# - a resource tomcat::instance.
#
# Example usage:
#
#   tomcat::connector {"http-8080":
#     ensure   => present,
#     owner    => "root",
#     group    => "tomcat-admin",
#     instance => "tomcat1",
#     protocol => "HTTP/1.1",
#     port     => 8080,
#     manage   => true,
#   }
#
#   tomcat::instance { "tomcat1":
#     ensure    => present,
#     group     => "tomcat-admin",
#     manage    => true,
#     connector => ["http-8080"]
#   }
#
define tomcat::connector(
  $port,
  $instance           = undef,
  $ensure             = present,
  $owner              = 'tomcat',
  $group              = 'adm',
  $protocol           = 'HTTP/1.1',
  $uri_encoding       = 'UTF-8',
  $address            = false,
  $connection_timeout = 20000,
  $redirect_port      = 8443,
  $scheme             = false,
  $executor           = false,
  $options            = [],
  $manage             = false,
  $instance_basedir   = false,
  $server             = regsubst($name, '^([^:]+):[^:]+:[^:]+$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^([^:]+):[^:]+:[^:]+$', '\1'),
  },
  $service            = regsubst($name, '^[^:]+:([^:]+):.*$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:([^:]+):.*$', '\1'),
  },
  $connector          = regsubst($name, '^[^:]+:[^:]+:([^:]+)$', '\1') ? {
    $name   => undef,
    default => regsubst($name, '^[^:]+:[^:]+:([^:]+)$', '\1'),
  },
) {

  validate_re("${port}", '^[0-9]+$')
  validate_re($ensure, ['present', 'absent'])
  validate_string($owner)
  validate_string($group)
  validate_re("${connection_timeout}", '^[0-9]+$')
  validate_re("${redirect_port}", '^[0-9]+$')
  validate_array($options)
  validate_bool($manage)

  if $server != undef and $service != undef and $connector != undef {
    validate_string($server)
    validate_string($service)
    validate_string($connector)

    concat_fragment { "server.xml_${server}_service_${service}+20_${connector}":
      content => template('tomcat/connector.xml.erb'),
    }
  } else {
    validate_string($instance)

    $_basedir = $instance_basedir? {
      false   => $tomcat::instance_basedir,
      default => $instance_basedir,
    }
    validate_absolute_path($_basedir)

    if $owner == 'tomcat' {
      $filemode = '0460'
    } else {
      $filemode = '0664'
    }

    $require = $executor? {
      false   => undef,
      default => Tomcat::Executor[$executor],
    }

    concat_build { "connector_${name}": } ->
    file {"${_basedir}/${instance}/conf/connector-${name}.xml":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $filemode,
      source  => concat_output("connector_${name}"),
      replace => $manage,
      require => $require,
    }
    concat_fragment { "connector_${name}+01":
      content => template('tomcat/connector_header.xml.erb'),
    }
    concat_fragment { "connector_${name}+99":
      content => template('tomcat/connector_footer.xml.erb'),
    }

    if $::tomcat::version != 5 {
      concat_fragment { "server.xml_${instance}+03_connector_${name}":
        content => "  <!ENTITY connector-${name} SYSTEM \"connector-${name}.xml\">\n",
      }

      concat_fragment { "server.xml_${instance}+06_connector_${name}":
        content => "    <!-- See conf/connector-${name}.xml for this connector's config. -->
      &connector-${name};\n",
      }
    }
  }

}
