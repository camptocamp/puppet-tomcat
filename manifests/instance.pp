# == Definition: tomcat::instance
#
# This definition will create:
# - a CATALINA_BASE directory in /srv/tomcat/$name/, readable to tomcat,
#   writeable to members of the admin group.
# - /srv/tomcat/$name/conf/{server,web}.xml which can be modified by members of
#   the admin group.
# - a /srv/tomcat/$name/webapps/ directory where administrators can drop "*.war"
#   files.
# - an init script /etc/init.d/tomcat-$name.
# - /srv/tomcat/$name/bin/setenv.sh, which is loaded by the init script.
# - /srv/tomcat/$name/bin/setenv-local.sh, which is loaded by the setenv.sh, and
#   can be edited by members of the admin group.
# - rotation of /srv/tomcat/$name/logs/catalina.out.
#
# Parameters:
#
# - *name*: the name of the instance.
# - *ensure*: defines if the state of the instance. Possible values:
#   - present: tomcat instance will be running and enabled on boot. This is the
#     default.
#   - running: an alias to "ensure => present".
#   - stopped: tomcat instance will be forced to stop, and disabled from boot,
#     but the files won't be erased from the system.
#   - installed: tomcat instance will be disabled from boot, and puppet won't
#     care if it's running or not. Useful if tomcat is managed by heartbeat.
#   - absent: tomcat instance will be stopped, disabled and completely removed
#     from the system. Warning: /srv/tomcat/$name/ will be completely erased !
# - *owner": the owner of $CATALINA_BASE/{conf,webapps}. Defaults to "tomcat".
#   Note that permissions will be different, as tomcat needs to read these
#   directories in any case.
# - *group*: the group which will be allowed to edit the instance's
#   configuration files and deploy webapps. Defaults to "adm".
# - *server_port*: tomcat's server port, defaults to 8005.
# - *http_port*: tomcat's HTTP server port, defaults to 8080.
# - *http_address*: define the IP address tomcat's HTTP server must listen on.
#   Defaults to all addresses.
# - *ajp_port*: tomcat's AJP port, defaults to 8009.
# - *ajp_address*: define the IP address tomcat's AJP server must listen on.
#   Defaults to all addresses.
# - *conf_mode*: can be used to change the permissions on
#   /srv/tomcat/$name/conf/, because some webapps require the ability to write
#   their own config files. Defaults to 2570 (writeable only by $group members).
# - *logs_mode*: can be used to change the permissions on
#   /srv/tomcat/$name/logs/, because you may need to make the logs readable
#   by other users / everyone. Defaults to 2770.
# - *server_xml_file*: can be used to set a specific server.xml file
# - *web_xml_file*: can be used to set a specific web.xml file
# - *webapp_mode*: can be used to change the permissions on
#   /srv/tomcat/$name/webapps/. Defaults to 2770 (readable and writeable by
#   $group members and tomcat himself, for auto-deploy).
# - *java_home*: can be used to define an alternate $JAVA_HOME, if you want the
#   instance to use another JVM.
# - *sample*: set to "true" and a basic "hello world" webapp will be deployed on
#   the instance. You can test it by loading this URL:
#   http://localhost:8080/sample (where 8080 is the port defined by the
#   "http_port" parameter).
# - *setenv*: optional array of environment variable definitions, which will be
#   added to setenv.sh. It will still be possible to override these variables by
#   editing setenv-local.sh.
# - *connector*: an array of tomcat::connector name (string) to include in
#   server.xml
# - *executor*: an array of tomcat::executor name (string) to include in
#   server.xml
# - *catalina_logrotate*: install an UNMANAGED logrotate configuration file,
#   to handle the catalina.out file of the instance. Default to true.
#
# Requires:
# - one of the tomcat classes which installs tomcat binaries.
# - java to be previously installed.
# - logrotate to be installed.
#
# Example usage:
#
#   include tomcat
#   include tomcat::administration
#
#   tomcat::instance { "foo":
#     ensure => present,
#     group  => "tomcat-admin",
#   }
#
#   tomcat::instance { "bar":
#     ensure      => present,
#     server_port => 8006,
#     http_port   => 8081,
#     ajp_port    => 8010,
#     sample      => true,
#     setenv      => [
#       'JAVA_XMX="1200m"',
#       'ADD_JAVA_OPTS="-Xms128m"'
#     ],
#   }
#
define tomcat::instance(
  $ensure             = present,
  $owner              = 'tomcat',
  $group              = 'adm',
  $server_port        = '8005',
  $http_port          = '8080',
  $http_address       = false,
  $ajp_port           = '8009',
  $ajp_address        = false,
  $conf_mode          = '',
  $logs_mode          = '',
  $server_xml_file    = '',
  $web_xml_file       = '',
  $webapp_mode        = '',
  $java_home          = '',
  $sample             = undef,
  $setenv             = [],
  $connector          = [],
  $default_connectors = true,
  $executor           = [],
  $manage             = false,
  $seluser            = 'system_u',
  $selrole            = 'object_r',
  $seltype            = 'initrc_exec_t',
  $instance_basedir   = $tomcat::instance_basedir,
  $tomcat_version     = $tomcat::version,
  $catalina_logrotate = true,
) {

  Class['tomcat::install'] -> Tomcat::Instance[$title]

  validate_re($ensure, [
    'present',
    'running',
    'stopped',
    'installed',
    'absent'
    ])
  validate_string($owner)
  validate_string($group)
  validate_bool($manage)
  validate_absolute_path($instance_basedir)

  $version = $tomcat_version
  validate_re($version, '^[5-8]([\.0-9]+)?$')

  $basedir = "${instance_basedir}/${name}"

  tomcat::instance::install { $title:
    catalina_base => $basedir,
  } ->
  tomcat::instance::config { $title:
    catalina_base => $basedir,
  } ->
  tomcat::instance::service { $title: }

  if $manage {
    Tomcat::Instance::Config[$title] ~> Tomcat::Instance::Service[$title]
  }
}
