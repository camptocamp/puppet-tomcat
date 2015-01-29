define tomcat::instance::config(
  $catalina_base,
  $ajp_address,
  $ajp_port,
  $connector,
  $default_connectors,
  $ensure,
  $executor,
  $group,
  $umask,
  $http_address,
  $http_port,
  $instance_basedir,
  $manage,
  $owner,
  $selrole,
  $seltype,
  $seluser,
  $server_port,
  $setenv,
  $version,
  # FIXME: This is really weird, I have to initialise this parameters otherwise
  # they are not found...
  $java_home       = undef,
  $server_xml_file = undef,
  $web_xml_file    = undef,
) {
  # lint:ignore:only_variable_string
  validate_re("${server_port}", '^[0-9]+$')
  validate_re("${http_port}", '^[0-9]+$')
  validate_re("${ajp_port}", '^[0-9]+$')
  # lint:endignore
  validate_array($setenv)
  validate_array($connector)
  validate_array($executor)

  ###
  # Configure connectors
  #
  if $connector == [] and $server_xml_file == undef and $default_connectors {

    $connectors = ["http-${http_port}-${name}","ajp-${ajp_port}-${name}"]

    $connector_ensure = $ensure? {
      'absent'  => absent,
      default => present,
    }

    tomcat::connector{"http-${http_port}-${name}":
      ensure           => $connector_ensure,
      instance         => $name,
      protocol         => 'HTTP/1.1',
      port             => $http_port,
      manage           => $manage,
      address          => $http_address,
      group            => $group,
      owner            => $owner,
      instance_basedir => $instance_basedir,
    }

    tomcat::connector{"ajp-${ajp_port}-${name}":
      ensure           => $connector_ensure,
      instance         => $name,
      protocol         => 'AJP/1.3',
      port             => $ajp_port,
      manage           => $manage,
      address          => $ajp_address,
      group            => $group,
      owner            => $owner,
      instance_basedir => $instance_basedir,
    }

  } else {
    $connectors = $connector
  }

  ###
  # Configure server.xml and web.xml
  #

  # default server.xml is slightly different between tomcat5.5 and tomcat6 or 7
  $serverdotxml = $version? {
    '5' => 'server.xml.tomcat55.erb',
    '6' => 'server.xml.tomcat6.erb',
    '7' => 'server.xml.tomcat7.erb',
  }

  case $ensure {
    'present','installed','running','stopped': {
      if $version != '5' {
        concat_build { "server.xml_${name}": }
        concat_fragment { "server.xml_${name}+01_header":
          content => '<?xml version=\'1.0\' encoding=\'utf-8\'?>
          <!DOCTYPE server-xml [
            ',
          }
        concat_fragment { "server.xml_${name}+04_body1":
          content => template("${module_name}/body1_${serverdotxml}"),
        }
        concat_fragment { "server.xml_${name}+07_body2":
          content => template("${module_name}/body2_${serverdotxml}"),
        }
      }

      $filemode = $owner ? {
        'tomcat' => '0460',
        default  => '0664',
      }

      # lint:ignore:selector_inside_resource
      file {
        "${catalina_base}/conf/server.xml":
          ensure  => file,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $server_xml_file? {
            undef   => $version ? {
              '5'     => undef,
              default => concat_output("server.xml_${name}"),
            },
            default => $server_xml_file,
          },
          content => $server_xml_file? {
            undef   => $version ? {
              '5'     => template("${module_name}/${serverdotxml}"),
              default => undef,
            },
            default => undef,
          },
          require => $server_xml_file? {
            undef   => $version ? {
              '5'     => undef,
              default => Concat_build["server.xml_${name}"],
            },
            default => Tomcat::Connector[$connectors],
          },
          replace => $manage,
          ;

        "${catalina_base}/conf/web.xml":
          ensure  => present,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $web_xml_file,
          content => $web_xml_file? {
            undef   => template("${module_name}/web.xml.erb"),
            default => undef,
          },
          replace => $manage,
          ;

      }
      # lint:endignore
    }
    'absent': {
      # do nothing
    }
    default: {
      fail "Unknown ensure value : ${ensure}"
    }
  }

  ###
  # Configure setenv.sh and setenv-local.sh
  #
  $present = $ensure ? {
    'present'   => 'file',
    'installed' => 'file',
    'running'   => 'file',
    'stopped'   => 'file',
    'absent'    => 'absent',
  }

  if $tomcat::type == 'package' and
      $::osfamily == 'RedHat' and
      $::operatingsystemmajrelease == 6 {
    # force catalina.sh to use the common library
    # in CATALINA_HOME and not CATALINA_BASE
    $classpath = "/usr/share/tomcat${version}/bin/tomcat-juli.jar"
  }

  # Default JVM options
  concat_build { "setenv.sh_${name}": } ->
  file {"${catalina_base}/bin/setenv.sh":
    ensure => $present,
    source => concat_output("setenv.sh_${name}"),
    owner  => 'root',
    group  => $group,
    mode   => '0754',
  }
  concat_fragment { "setenv.sh_${name}+01_header":
    content => template('tomcat/setenv.sh.header.erb'),
  }
  concat_fragment { "setenv.sh_${name}+99_footer":
    content => template('tomcat/setenv.sh.footer.erb'),
  }

  # User customized JVM options
  file {"${catalina_base}/bin/setenv-local.sh":
    ensure  => $present,
    replace => false,
    content => template('tomcat/setenv-local.sh.erb'),
    owner   => 'root',
    group   => $group,
    mode    => '0574',
  }

  ###
  # Configure Init script
  #
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7' {
    include ::systemd

    file { "/usr/lib/systemd/system/tomcat-${name}.service":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => '/usr/lib/systemd/system/tomcat.service',
      replace => false,
    } ->
    ini_setting { 'UMASK':
      ensure            => present,
      path              => "/usr/lib/systemd/system/tomcat-${name}.service",
      section           => 'Service',
      setting           => 'UMask',
      key_val_separator => '=',
      value             => $umask,
    } ->
    ini_setting { 'SERVICE_NAME':
      ensure            => present,
      path              => "/usr/lib/systemd/system/tomcat-${name}.service",
      section           => 'Service',
      setting           => 'Environment',
      key_val_separator => '=',
      value             => "\"SERVICE_NAME=tomcat-${name}\"",
    } ~>
    Exec['systemctl-daemon-reload']

    file { "/etc/sysconfig/tomcat-${name}":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0664',
      source  => '/etc/sysconfig/tomcat',
      replace => false,
      notify  => Service["tomcat-${name}"],
    } ->
    shellvar { "CATALINA_BASE_${name}":
      ensure    => present,
      target    => "/etc/sysconfig/tomcat-${name}",
      variable  => 'CATALINA_BASE',
      value     => $catalina_base,
      uncomment => true,
    } ->
    augeas { "setenv.sh_${name}":
      lens    => 'Shellvars.lns',
      incl    => "/etc/sysconfig/tomcat-${name}",
      changes => [
        "rm .source[.='${catalina_base}/bin/setenv.sh']",
        "set .source[.='${catalina_base}/bin/setenv.sh'] '${catalina_base}/bin/setenv.sh'",
      ],
    }
  } else {
    # Variables used in tomcat.init.erb
    $tomcat_name = $name

    if $tomcat::type == 'package' {
      $catalinahome = $version? {
        5        => $::osfamily? {
          'RedHat' => '/usr/share/tomcat5',
          'Debian' => '/usr/share/tomcat5.5',
        },
        default  => "/usr/share/tomcat${version}",
      }
    }

    # In this case, we are using a non package-based tomcat.
    if $tomcat::type == 'sources' {
      $catalinahome = '/opt/apache-tomcat'
    }

    # Define a version string for use in templates
    $tomcat_version_str = "${version}_${tomcat::type}"

    # Define default JAVA_HOME used in tomcat.init.erb
    if $java_home == undef {
      case $::osfamily {
        'RedHat': {
          if $::operatingsystem == 'CentOS' {
            $javahome = '/etc/alternatives/jre'
          } else {
            $javahome = '/usr/lib/jvm/java'
          }
        }
        'Debian': {
          $javahome = '/usr'
        }
        default: {
          err("java_home not defined for operatingsystem '${::operatingsystem}'.")
        }
      }
    } else {
      $javahome = $java_home
    }
    validate_absolute_path($javahome)

    file {"/etc/init.d/tomcat-${name}":
      ensure  => $present,
      content => template('tomcat/tomcat.init.erb'),
      owner   => 'root',
      mode    => '0755',
      require => File["${catalina_base}/bin/setenv.sh"],
      seluser => $seluser,
      selrole => $selrole,
      seltype => $seltype,
    }
  }
}
