define tomcat::env(
  $instance,
  $key   = regsubst($name, '^([^=]+).*', '\1'),
  $value = regsubst($name, '^[^=]+="?([^"]*)"?$', '\1'),
) {
  if $::tomcat::distro_way {
    $distro_confdir = $::osfamily ? {
      'Debian' => '/etc/default',
      'RedHat' => '/etc/sysconfig',
    }

    shellvar { "${key}_${instance}":
      ensure   => present,
      target   => "${distro_confdir}/tomcat-${instance}",
      variable => $key,
      value    => $value,
    }
  } else {
    concat_fragment { "setenv.sh_${instance}+02_${name}":
      content => "export ${key}=\"${value}\"",
    }
  }
}
