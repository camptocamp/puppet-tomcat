define tomcat::instance::config(
  $catalina_base,
) {
  $ajp_address        = getparam(Tomcat::Instance[$title], 'ajp_address')
  $ajp_port           = getparam(Tomcat::Instance[$title], 'ajp_port')
  $connector          = getparam(Tomcat::Instance[$title], 'connector')
  $default_connectors = getparam(Tomcat::Instance[$title], 'default_connectors')
  $ensure             = getparam(Tomcat::Instance[$title], 'ensure')
  $executor           = getparam(Tomcat::Instance[$title], 'executor')
  $group              = getparam(Tomcat::Instance[$title], 'group')
  $http_address       = getparam(Tomcat::Instance[$title], 'http_address')
  $http_port          = getparam(Tomcat::Instance[$title], 'http_port')
  $instance_basedir   = getparam(Tomcat::Instance[$title], 'instance_basedir')
  $java_home          = getparam(Tomcat::Instance[$title], 'java_home')
  $manage             = str2bool(getparam(Tomcat::Instance[$title], 'manage'))
  $owner              = getparam(Tomcat::Instance[$title], 'owner')
  $selrole            = getparam(Tomcat::Instance[$title], 'selrole')
  $seltype            = getparam(Tomcat::Instance[$title], 'seltype')
  $seluser            = getparam(Tomcat::Instance[$title], 'seluser')
  $server_port        = getparam(Tomcat::Instance[$title], 'server_port')
  $server_xml_file    = getparam(Tomcat::Instance[$title], 'server_xml_file')
  $setenv             = getparam(Tomcat::Instance[$title], 'setenv')
  $version            = getparam(Tomcat::Instance[$title], 'tomcat_version')
  $web_xml_file       = getparam(Tomcat::Instance[$title], 'web_xml_file')

  # lint:ignore:only_variable_string
  validate_re("${server_port}", '^[0-9]+$')
  validate_re("${http_port}", '^[0-9]+$')
  validate_re("${ajp_port}", '^[0-9]+$')
  # lint:endignore
  validate_array($setenv)
  validate_array($connector)
  validate_array($executor)

  if $ensure != 'absent' {

    $filemode = $owner ? {
      'tomcat' => '0460',
      default  => '0664',
    }

    ###
    # Configure setenv-local.sh
    #
    file {"${catalina_base}/bin/setenv-local.sh":
      ensure  => file,
      replace => false,
      content => template('tomcat/setenv-local.sh.erb'),
      owner   => 'root',
      group   => $group,
      mode    => '0574',
    }

    if $::tomcat::distro_way {
      if versioncmp($::augeasversion, '1.0.0') < 0 {
        fail('Require Augeas >= 1.0.0')
      }

      $distro_confdir = $::osfamily ? {
        'Debian' => '/etc/default',
        'RedHat' => '/etc/sysconfig',
      }
      $distro_conffile = $::osfamily ? {
        'Debian' => "${distro_confdir}/tomcat${version}",
        'RedHat' => "${distro_confdir}/tomcat",
      }
      $distro_tomcat_confdir = $::osfamily ? {
        'Debian' => "/etc/tomcat${version}",
        'RedHat' => '/etc/tomcat',
      }

      ###
      # Environment variables
      #
      file { "${distro_confdir}/tomcat-${name}":
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => $distro_conffile,
        replace => false,
      } ->
      shellvar { "CATALINA_BASE_${name}":
        ensure    => present,
        target    => "${distro_confdir}/tomcat-${name}",
        variable  => 'CATALINA_BASE',
        value     => $catalina_base,
        uncomment => true,
      } ->
      # FIXME: this removes commented lines from config file...
      #      tomcat::env { $setenv:
      #        instance => $name,
      #      } ->
      augeas { "setenv-local.sh_${name}":
        lens    => 'Shellvars.lns',
        incl    => "${distro_confdir}/tomcat-${name}",
        changes => [
          "rm .source[.='${catalina_base}/bin/setenv-local.sh']",
          "set .source[.='${catalina_base}/bin/setenv-local.sh'] '${catalina_base}/bin/setenv-local.sh'",
        ],
      }

      ###
      # Server.xml
      #
      file { "${catalina_base}/conf/server.xml":
        ensure  => file,
        owner   => $owner,
        group   => $group,
        mode    => $filemode,
        source  => "${distro_tomcat_confdir}/server.xml",
        replace => false,
      } ->
      augeas { "http_port_${name}":
        lens    => 'Xml.lns',
        incl    => "${catalina_base}/conf/server.xml",
        context => "/files${catalina_base}/conf/server.xml",
        changes => "set Server/Service[#attribute/name='Catalina']/Connector[#attribute/protocol='HTTP/1.1']/#attribute/port ${http_port}",
      } ->
      augeas { "server_port_${name}":
        lens    => 'Xml.lns',
        incl    => "${catalina_base}/conf/server.xml",
        context => "/files${catalina_base}/conf/server.xml",
        changes => "set Server/#attribute/port ${server_port}",
      }

      ###
      # Web.xml
      #
      file { "${catalina_base}/conf/web.xml":
        ensure => file,
        owner  => $owner,
        group  => $group,
        mode   => $filemode,
        source => "${distro_tomcat_confdir}/web.xml",
      }

      case $::osfamily {
        'Debian': {

          shellvar { "TOMCAT${version}_USER_${name}":
            ensure    => present,
            target    => "${distro_confdir}/tomcat-${name}",
            variable  => "TOMCAT${version}_USER",
            value     => $owner,
            uncomment => true,
          }

          shellvar { "TOMCAT${version}_GROUP_${name}":
            ensure    => present,
            target    => "${distro_confdir}/tomcat-${name}",
            variable  => "TOMCAT${version}_GROUP",
            value     => $owner,
            uncomment => true,
          }

          ###
          # Init script
          #
          if $version < 7 {
            File_line {
              path    => "/etc/init.d/tomcat-${name}",
              require => File["/etc/init.d/tomcat-${name}"],
            }

            file { "/etc/init.d/tomcat-${name}":
              ensure  => file,
              owner   => 'root',
              group   => 'root',
              mode    => '0755',
              source  => "/etc/init.d/tomcat${version}",
              replace => false,
            }

            file_line { "Title_${name}":
              line  => "# /etc/init.d/tomcat-${name}",
              match => '^# /etc/init.d/tomcat',
            }

            file_line { "Provides_${name}":
              line  => "# Provides:          tomcat-${name}",
              match => '^# Provides:',
            }
          } else {
            # TODO: Debian's tomcat7+ init script is not multi version away anymore...
            notice "FIXME: Debian's tomcat7+ init script is not multi version away anymore..."
          }
        }
        'RedHat': {
          augeas { "ajp_port_${name}":
            lens    => 'Xml.lns',
            incl    => "${catalina_base}/conf/server.xml",
            context => "/files${catalina_base}/conf/server.xml",
            changes => "set Server/Service[#attribute/name='Catalina']/Connector[#attribute/protocol='AJP/1.3']/#attribute/port ${ajp_port}",
            require => File["${catalina_base}/conf/server.xml"],
          }
          ###
          # Systemd service file
          #

          include ::systemd

          file { "/usr/lib/systemd/system/tomcat-${name}.service":
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            source  => '/usr/lib/systemd/system/tomcat.service',
            replace => false,
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
        }
        default: {
          fail "Unsupported Operating System family: ${::osfamily}"
        }
      }

    } else {
      ###
      # Configure connectors
      #
      if $connector == [] and $server_xml_file == '' and $default_connectors {

        $connectors = ["http-${http_port}-${name}","ajp-${ajp_port}-${name}"]

        $connector_ensure = $ensure? {
          absent  => absent,
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
        5 => 'server.xml.tomcat55.erb',
        6 => 'server.xml.tomcat6.erb',
        7 => 'server.xml.tomcat7.erb',
      }

      if $version != 5 {
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

      # lint:ignore:selector_inside_resource
      file {
        "${catalina_base}/conf/server.xml":
          ensure  => file,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $server_xml_file? {
            ''      => $version ? {
              5       => undef,
              default => concat_output("server.xml_${name}"),
            },
            default => $server_xml_file,
          },
          content => $server_xml_file? {
            ''      => $version ? {
              5       => template("${module_name}/${serverdotxml}"),
              default => undef,
            },
            default => undef,
          },
          require => $server_xml_file? {
            ''      => $version ? {
              5       => undef,
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
          source  => $web_xml_file? {
            ''      => undef,
            default => $web_xml_file,
          },
          content => $web_xml_file? {
            ''      => template("${module_name}/web.xml.erb"),
            default => undef,
          },
          replace => $manage,
          ;

      # lint:endignore
      }

      ###
      # Configure setenv.sh
      #
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
        ensure => file,
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

      ###
      # Configure Init script
      #

      # Variables used in tomcat.init.erb
      $tomcat_name = $name

      if $tomcat::type == 'package' {
        $catalinahome = $version? {
          5        => $::osfamily? {
            RedHat => '/usr/share/tomcat5',
            Debian => '/usr/share/tomcat5.5',
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
      if $java_home == '' {
        case $::osfamily {
          RedHat: {
            $javahome = '/usr/lib/jvm/java'
          }
          Scientific: {
            $javahome = '/usr/lib/jvm/java'
          }
          CentOS: {
            $javahome = '/etc/alternatives/jre'
          }
          SLC: {
            $javahome = '/usr/lib/jvm/jre'
          }
          Debian,Ubuntu: {
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
        ensure  => file,
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
}
