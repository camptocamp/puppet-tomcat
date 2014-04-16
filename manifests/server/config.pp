define tomcat::server::config(
  $basedir,
  $port,
  $setenv,
  $shutdown,
  $group = 'adm',
  $owner = 'tomcat',
) {
  # Default JVM options
  concat_build { "setenv.sh_${name}": } ->
  file {"${basedir}/bin/setenv.sh":
    content => concat_output("setenv.sh_${name}"),
    owner   => 'root',
    group   => $group,
    mode    => '0754',
  }
  concat_fragment { "setenv.sh_${name}+01_header":
    content => template('tomcat/setenv.sh.header.erb'),
  }
  concat_fragment { "setenv.sh_${name}+99_footer":
    content => template('tomcat/setenv.sh.footer.erb'),
  }

  # User customized JVM options
  file {"${basedir}/bin/setenv-local.sh":
    replace => false,
    content => template('tomcat/setenv-local.sh.erb'),
    owner   => 'root',
    group   => $group,
    mode    => '0574',
  }

  # Nobody usually write there
  file { $basedir:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => '0555',
  }

  file { "${basedir}/bin":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  }

  # Developpers usually write there
  file { "${basedir}/conf":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '2570',
  }

  file { "${basedir}/lib":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '2775',
  }

  file { "${basedir}/private":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '2775',
  }

  file { "${basedir}/conf/server.xml":
    ensure => file,
    owner  => $owner,
    group  => $group,
    mode   => '0460',
    source => concat_output("server.xml_${name}"),
  }

  file { "${basedir}/conf/web.xml":
    ensure  => present,
    owner   => $owner,
    group   => $group,
    mode    => '0460',
    content => template('tomcat/web.xml.erb'),
  }

  file { "${basedir}/README":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('tomcat/README.erb'),
  }

  file { "${basedir}/webapps":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '2770',
  }

  # Tomcat usually write there
  file { "${basedir}/logs":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '2770',
  }

  file { "${basedir}/work":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '2770',
  }

  file { "${basedir}/temp":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '2770',
  }

  concat_build { "server.xml_${name}": }

  concat_fragment { "server.xml_${name}+01":
    content => "<?xml version='1.0' encoding='utf-8'?>
<Server port=\"${port}\" shutdown=\"${shutdown}\">",
  }
  concat_fragment { "server.xml_${name}+99":
    content => '</Server>',
  }

}
