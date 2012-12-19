/*

== Definition: tomcat::instance

This definition will create:
- a CATALINA_BASE directory in /srv/tomcat/$name/, readable to tomcat,
  writeable to members of the admin group.
- /srv/tomcat/$name/conf/{server,web}.xml which can be modified by members of
  the admin group.
- a /srv/tomcat/$name/webapps/ directory where administrators can drop "*.war"
  files.
- an init script /etc/init.d/tomcat-$name.
- /srv/tomcat/$name/bin/setenv.sh, which is loaded by the init script.
- /srv/tomcat/$name/bin/setenv-local.sh, which is loaded by the setenv.sh, and
  can be edited by members of the admin group.
- rotation of /srv/tomcat/$name/logs/catalina.out.

Parameters:

- *name*: the name of the instance.
- *ensure*: defines if the state of the instance. Possible values:
  - present: tomcat instance will be running and enabled on boot. This is the
    default.
  - running: an alias to "ensure => present".
  - stopped: tomcat instance will be forced to stop, and disabled from boot,
    but the files won't be erased from the system.
  - installed: tomcat instance will be disabled from boot, and puppet won't
    care if it's running or not. Useful if tomcat is managed by heartbeat.
  - absent: tomcat instance will be stopped, disabled and completely removed
    from the system. Warning: /srv/tomcat/$name/ will be completely erased !
- *owner": the owner of $CATALINA_BASE/{conf,webapps}. Defaults to "tomcat".
  Note that permissions will be different, as tomcat needs to read these
  directories in any case.
- *group*: the group which will be allowed to edit the instance's configuration
  files and deploy webapps. Defaults to "adm".
- *server_port*: tomcat's server port, defaults to 8005.
- *http_port*: tomcat's HTTP server port, defaults to 8080.
- *http_address*: define the IP address tomcat's HTTP server must listen on.
  Defaults to all addresses.
- *ajp_port*: tomcat's AJP port, defaults to 8009.
- *ajp_address*: define the IP address tomcat's AJP server must listen on.
  Defaults to all addresses.
- *conf_mode*: can be used to change the permissions on
  /srv/tomcat/$name/conf/, because some webapps require the ability to write
  their own config files. Defaults to 2570 (writeable only by $group members).
- *server_xml_file*: can be used to set a specific server.xml file
- *web_xml_file*: can be used to set a specific web.xml file
- *webapp_mode*: can be used to change the permissions on
  /srv/tomcat/$name/webapps/. Defaults to 2770 (readable and writeable by
  $group members and tomcat himself, for auto-deploy).
- *java_home*: can be used to define an alternate $JAVA_HOME, if you want the
  instance to use another JVM.
- *sample*: set to "true" and a basic "hello world" webapp will be deployed on
  the instance. You can test it by loading this URL:
  http://localhost:8080/sample (where 8080 is the port defined by the
  "http_port" parameter).
- *setenv*: optional array of environment variable definitions, which will be
  added to setenv.sh. It will still be possible to override these variables by
  editing setenv-local.sh.
- *connector*: an array of tomcat::connector name (string) to include in server.xml
- *executor*: an array of tomcat::executor name (string) to include in server.xml

Requires:
- one of the tomcat classes which installs tomcat binaries.
- java to be previously installed.
- logrotate to be installed.

Example usage:

  include tomcat
  include tomcat::administration

  tomcat::instance { "foo":
    ensure => present,
    group  => "tomcat-admin",
  }

  tomcat::instance { "bar":
    ensure      => present,
    server_port => 8006,
    http_port   => 8081,
    ajp_port    => 8010,
    sample      => true,
    setenv      => [
      'JAVA_XMX="1200m"',
      'ADD_JAVA_OPTS="-Xms128m"'
    ],
  }

*/
define tomcat::instance($ensure="present",
                        $owner="tomcat",
                        $group="adm",
                        $server_port="8005",
                        $http_port="8080",
                        $http_address=false,
                        $ajp_port="8009",
                        $ajp_address=false,
                        $conf_mode="",
                        $server_xml_file="",
                        $web_xml_file="",
                        $webapp_mode="",
                        $java_home="",
                        $sample=undef,
                        $setenv=[],
                        $connector=[],
                        $executor=[],
                        $manage=false,
                        $seluser=undef,
                        $selrole=undef,
                        $seltype=undef) {

  include tomcat::params
  
  $tomcat_name = $name
  $basedir = "${tomcat::params::instance_basedir}/${name}"

  if $owner == 'tomcat' {
    $dirmode  = $webapp_mode ? {
      ''      => '2770',
      default => $webapp_mode,
    }
    $filemode = '0460'
    $confmode = $conf_mode ? {
      ''      => '2570',
      default => $conf_mode
    }

  } else {
    $dirmode  = $webapp_mode ? {
      ''      => '2775',
      default => $webapp_mode,
    }
    $filemode = '0664'
    $confmode = $conf_mode ? {
      ''      => $dirmode,
      default => $conf_mode
    }
  }

  if $connector == [] and $server_xml_file == '' {
    
    $connectors = ["http-${http_port}-${name}","ajp-${ajp_port}-${name}"]
    
    tomcat::connector{"http-${http_port}-${name}":
      ensure   => $ensure ? {
        'absent' => absent,
        default  => present,
      },
      instance => $name,
      protocol => 'HTTP/1.1',
      port     => $http_port,
      manage   => $manage,
      address  => $http_address,
      group    => $group,
      owner    => $owner
    }

    tomcat::connector{"ajp-${ajp_port}-${name}":
      ensure   => $ensure ? {
        'absent' => absent,
        default  => present,
      },
      instance => $name,
      protocol => 'AJP/1.3',
      port     => $ajp_port,
      manage   => $manage,
      address  => $ajp_address,
      group    => $group,
      owner    => $owner
    }

  } else {
    $connectors = $connector
  }

  if defined(File[$tomcat::params::instance_basedir]) {
    debug "File[${tomcat::params::instance_basedir}] already defined"
  } else {
    file {$tomcat::params::instance_basedir:
      ensure => directory,
    }
  }

  if $tomcat::params::type == "package" and $::osfamily == 'RedHat' and $::operatingsystemrelease =~ /^6.*/ {
    # force catalina.sh to use the common library in CATALINA_HOME and not CATALINA_BASE
    $classpath = '/usr/share/tomcat6/bin/tomcat-juli.jar'
  }

  # default server.xml is slightly different between tomcat5.5 and tomcat6
  if $tomcat::params::maj_version == '5.5' {
    $serverdotxml = 'server.xml.tomcat55.erb'
  }

  if $tomcat::params::maj_version == '6' {
    $serverdotxml = 'server.xml.tomcat6.erb'
  }

  if $tomcat::params::maj_version == '5.5' and $tomcat::params::type == 'package' {
    $catalinahome = $::osfamily ? {
      RedHat => '/usr/share/tomcat5',
      Debian => '/usr/share/tomcat5.5',
    }
  }

  if $tomcat::params::maj_version == '6' and $tomcat::params::type == 'package' {
    $catalinahome = $::osfamily ? {
      RedHat => '/usr/share/tomcat6',
      Debian => '/usr/share/tomcat6',
    }
  }

  # In this case, we are using a non package-based tomcat.
  if $tomcat::params::type == 'source' {
    $catalinahome = '/opt/apache-tomcat'
  }

  # Define a version string for use in templates
  $tomcat_version_str = "${tomcat::params::maj_version}_${tomcat::params::type}"

  # Define default JAVA_HOME used in tomcat.init.erb
  if $java_home == '' {
    case $::operatingsystem {
      RedHat: {
        $javahome = '/usr/lib/jvm/java'
      }
      CentOS: {
        $javahome = '/etc/alternatives/jre'
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

  # Instance directories
  case $ensure {
    present,installed,running,stopped: {
      file {
        # Nobody usually write there
        $basedir:
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => '0555',
          before => Service["tomcat-${name}"],
          require => $group ? {
            'adm'   => undef,
            default => Group[$group],
          };

        "${basedir}/bin":
          ensure => directory,
          owner  => 'root',
          group  => $group,
          mode   => 755,
          before => Service["tomcat-${name}"];

        # Developpers usually write there
        "${basedir}/conf":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $confmode,
          before => Service["tomcat-${name}"];

        "${basedir}/lib":
          ensure => directory,
          owner  => 'root',
          group  => $group,
          mode   => 2775,
          before => Service["tomcat-${name}"];

        "${basedir}/private":
          ensure => directory,
          owner  => 'root',
          group  => $group,
          mode   => 2775,
          before => Service["tomcat-${name}"];

        "${basedir}/conf/server.xml":
          ensure  => present,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $server_xml_file? {
            ''      => undef,
            default => $server_xml_file,
          },
          content => $server_xml_file? {
            ''      => template("tomcat/${serverdotxml}"),
            default => undef,
          },
          before  => Service["tomcat-${name}"],
          notify  => $manage? {
            true    => Service["tomcat-${name}"],
            default => undef,
          },
          require => $server_xml_file? {
            ''      => undef,
            default => Tomcat::Connector[$connectors],
          },
          replace => $manage;

        "${basedir}/conf/web.xml":
          ensure  => present,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $web_xml_file? {
            ''      => undef,
            default => $web_xml_file,
          },
          content => $web_xml_file? {
            ''      => template('tomcat/web.xml.erb'),
            default => undef,
          },
          before  => Service["tomcat-${name}"],
          notify  => $manage? {
            true    => Service["tomcat-${name}"],
            default => undef,
          },
          replace => $manage;

        "${basedir}/README":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => 644,
          content => template('tomcat/README.erb');

        "${basedir}/webapps":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $dirmode,
          before => Service["tomcat-${name}"];
    
        # Tomcat usually write there
        "${basedir}/logs":
          ensure => directory,
          owner  => 'tomcat',
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/work":
          ensure => directory,
          owner  => 'tomcat',
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/temp":
          ensure => directory,
          owner  => 'tomcat',
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
      }

      if $sample {

        # Deploy a sample "Hello World" webapp available at:
        # http://localhost:8080/sample/
        #
        file { "${basedir}/webapps/sample.war":
          ensure  => present,
          owner   => 'tomcat',
          group   => $group,
          mode    => 0460,
          source  => 'puppet:///modules/tomcat/sample.war',
          require => File["${basedir}/webapps"],
          before => Service["tomcat-${name}"],
        }
      }
    }
    absent: {
      file {$basedir:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
  }

  $present = $ensure ? {
    present   => 'present',
    installed => 'present',
    running   => 'present',
    stopped   => 'present',
    absent    => 'absent',
  }


  # Default JVM options
  file {"${basedir}/bin/setenv.sh":
    ensure  => $present,
    content => template('tomcat/setenv.sh.erb'),
    owner   => 'root',
    group   => $group,
    mode    => 754,
    before  => Service["tomcat-${name}"],
  }

  # User customized JVM options
  file {"${basedir}/bin/setenv-local.sh":
    ensure  => $present,
    replace => false,
    content => template('tomcat/setenv-local.sh.erb'),
    owner  => 'root',
    group  => $group,
    mode   => 574,
    before => Service["tomcat-${name}"],
  }


  # Init and env scripts
  file {"/etc/init.d/tomcat-${name}":
    ensure  => $present,
    content => template("tomcat/tomcat.init.erb"),
    owner   => "root",
    mode    => "755",
    require => File["${basedir}/bin/setenv.sh"],
    seluser => $seluser ? {
            ''      => 'system_u',
            default => $seluser,
          },
    selrole => $selrole ? {
            ''      => 'object_r',
            default => $selrole,
          },
    seltype => $seltype ? {
            ''      => 'initrc_exec_t',
            default => $seltype,
          },
  }

  if $tomcat::params::type == "package" {
    $servicerequire = Package["tomcat"]
  } else {
    $servicerequire = File["/opt/apache-tomcat"]
  }

  service {"tomcat-${name}":
    ensure  => $ensure ? {
      present   => "running",
      running   => "running",
      stopped   => "stopped",
      installed => undef,
      absent    => "stopped",
    },
    enable  => $ensure ? {
      present   => true,
      running   => true,
      stopped   => false,
      installed => false,
      absent    => false,
    },
    require => [File["/etc/init.d/tomcat-${name}"], $servicerequire],
    pattern => "-Dcatalina.base=${tomcat::params::instance_basedir}/${name}",
  }

  # Logrotate
  file {"/etc/logrotate.d/tomcat-${name}.conf":
    ensure => absent,
  }
}
