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
  $apr_listener,
  # FIXME: This is really weird, I have to initialise this parameters otherwise
  # they are not found...
  $java_home         = undef,
  $server_xml_file   = undef,
  $web_xml_file      = undef,
  $java_opts         = undef,
  $systemd_nofile    = undef,
  $selrole_connector = undef,
  $seltype_connector = undef,
  $seluser_connector = undef,

  $system_conf_owner = $::tomcat::system_conf_owner,
  $system_conf_group = $::tomcat::system_conf_group,
  $system_conf_mod   = $::tomcat::system_conf_mod,
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
      seltype          => $seltype_connector,
      seluser          => $seluser_connector,
      selrole          => $selrole_connector,
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
      seltype          => $seltype_connector,
      seluser          => $seluser_connector,
      selrole          => $selrole_connector,
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
    '8' => 'server.xml.tomcat8.erb',
    '9' => 'server.xml.tomcat9.erb',
  }

  case $ensure {
    'present','installed','running','stopped': {
      $filemode = $owner ? {
        'tomcat' => '0460',
        default  => '0664',
      }

      if $server_xml_file {
        file { "${catalina_base}/conf/server.xml":
          ensure  => file,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $server_xml_file,
          content => undef,
          require => Tomcat::Connector[$connectors],
          seltype => $seltype_connector,
          seluser => $seluser_connector,
          selrole => $selrole_connector,
          replace => $manage,
        }
      } elsif $version == '5' {
        file { "${catalina_base}/conf/server.xml":
          ensure  => file,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => undef,
          content => template("${module_name}/${serverdotxml}"),
          replace => $manage,
          seltype => $seltype_connector,
          seluser => $seluser_connector,
          selrole => $selrole_connector,
        }
      } else {
        concat { "${catalina_base}/conf/server.xml":
          ensure  => present,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          replace => $manage,
          seltype => $seltype_connector,
          seluser => $seluser_connector,
          selrole => $selrole_connector,
        }
        concat::fragment { "server.xml_${name}+01_header":
          target  => "${catalina_base}/conf/server.xml",
          content => "<?xml version='1.0' encoding='utf-8'?>
          <!DOCTYPE server-xml [\n            \n",
          order   => '01',
        }
        concat::fragment { "server.xml_${name}+04_body1":
          target  => "${catalina_base}/conf/server.xml",
          content => template("${module_name}/body1_${serverdotxml}"),
          order   => '04',
        }
        concat::fragment { "server.xml_${name}+07_body2":
          target  => "${catalina_base}/conf/server.xml",
          content => template("${module_name}/body2_${serverdotxml}"),
          order   => '07',
        }
      }

      $web_xml_content = $web_xml_file ? {
        undef   => template("${module_name}/web.xml.erb"),
        default => undef,
      }
      file { "${catalina_base}/conf/web.xml":
        ensure  => 'file',
        owner   => $owner,
        group   => $group,
        mode    => $filemode,
        source  => $web_xml_file,
        content => $web_xml_content,
        replace => $manage,
        seltype => $seltype_connector,
        seluser => $seluser_connector,
        selrole => $selrole_connector,
      }
    }
    'absent': {
      # do nothing
    }
    default: {
      fail "Unknown ensure value : ${ensure}"
    }
  }

  if $tomcat::type == 'package' and
      $::osfamily == 'RedHat' and
      versioncmp($::operatingsystemmajrelease, '6') == 0 {
    # force catalina.sh to use the common library
    # in CATALINA_HOME and not CATALINA_BASE
    $classpath = "/usr/share/tomcat${version}/bin/tomcat-juli.jar"
  }

  ###
  # Configure Init script
  #
  if $::osfamily == 'RedHat' and $::tomcat::params::systemd {
    include ::systemd

    file {"${catalina_base}/bin/setenv.sh":
      ensure => absent,
    }
    file {"${catalina_base}/bin/setenv-local.sh":
      ensure  => absent,
    }

    file { "/usr/lib/systemd/system/tomcat-${name}.service":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => ".include /usr/lib/systemd/system/tomcat.service
[Service]
UMask=${umask}
LimitNOFILE=${systemd_nofile}
Environment=\"SERVICE_NAME=tomcat-${name}\"
EnvironmentFile=-/etc/sysconfig/tomcat-${name}
",
      notify  => Tomcat::Instance::Service[$title],
    }
    -> Tomcat::Instance::Service[$title]

    file { "/etc/sysconfig/tomcat-${name}":
      ensure  => file,
      owner   => $system_conf_owner,
      group   => $system_conf_group,
      mode    => $system_conf_mod,
      source  => '/etc/sysconfig/tomcat',
      replace => false,
      notify  => Service["tomcat-${name}"],
    }
    -> shellvar { "CATALINA_BASE_${name}":
      ensure    => present,
      target    => "/etc/sysconfig/tomcat-${name}",
      variable  => 'CATALINA_BASE',
      value     => $catalina_base,
      uncomment => true,
    }
    if $java_opts {
      shellvar { "JAVA_OPTS_${name}":
        ensure    => present,
        target    => "/etc/sysconfig/tomcat-${name}",
        variable  => 'JAVA_OPTS',
        value     => $java_opts,
        uncomment => true,
        require   => File["/etc/sysconfig/tomcat-${name}"],
      }
    }
    if $setenv {
      tomcat::instance::config::systemd_env {$setenv:
        instance => $name,
        target   => "/etc/sysconfig/tomcat-${name}",
      }
    }
  } else {
    ###
    # Configure setenv.sh and setenv-local.sh
    #
    $present = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }

    # Default JVM options
    concat {"${catalina_base}/bin/setenv.sh":
      ensure => $present,
      owner  => 'root',
      group  => $group,
      mode   => '0754',
    }
    concat::fragment { "setenv.sh_${name}+01_header":
      target  => "${catalina_base}/bin/setenv.sh",
      content => template('tomcat/setenv.sh.header.erb'),
      order   => '01',
    }
    concat::fragment { "setenv.sh_${name}+99_footer":
      target  => "${catalina_base}/bin/setenv.sh",
      content => template('tomcat/setenv.sh.footer.erb'),
      order   => '99',
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

    # Variables used in tomcat.init.erb
    $tomcat_name = $name
    $basedir     = $catalina_base

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
      require => Concat["${catalina_base}/bin/setenv.sh"],
      seluser => $seluser,
      selrole => $selrole,
      seltype => $seltype,
      notify  => Tomcat::Instance::Service[$title],
    }

    if $::operatingsystem == 'Debian' and $::tomcat::params::systemd {
      include ::systemd
      File["/etc/init.d/tomcat-${name}"]
      ~> Exec['systemctl-daemon-reload']
      -> Tomcat::Instance::Service[$title]
    }
  }
}
