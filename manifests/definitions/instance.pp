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
- *ensure*: defines if the instance must be present or not. Warning: if set to
  "absent", /srv/tomcat/$name/ will be completely erased !
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
- *java_home*: can be used to define an alternate $JAVA_HOME, if you want the
  instance to use another JVM.
- *sample*: set to "true" and a basic "hello world" webapp will be deployed on
  the instance. You can test it by loading this URL:
  http://localhost:8080/sample (where 8080 is the port defined by the
  "http_port" parameter).
- *setenv_content*: optional content for /srv/tomcat/$name/bin/setenv-local.sh.
  If defined, the file will no longer be manageable by members of the
  tomcat-admin group.

Requires:
- one of the tomcat classes which installs tomcat binaries.
- java to be previously installed.
- logrotate to be installed.

Example usage:

  include tomcat::package::v6
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
    setenv_content => 'export JAVA_XMX="1200m"'
  }

*/
define tomcat::instance($ensure="present",
                        $group="adm",
                        $server_port="8005",
                        $http_port="8080",
                        $http_address=false,
                        $ajp_port="8009",
                        $ajp_address=false,
                        $conf_mode=2570,
                        $java_home="",
                        $sample=undef,
                        $setenv_content=undef) {

  $basedir = "/srv/tomcat/${name}"

  if defined(File["/srv/tomcat"]) {
    debug "File[/srv/tomcat] already defined"
  } else {
    file {"/srv/tomcat":
      ensure => directory,
    }
  }

  # default server.xml is slightly different between tomcat5.5 and tomcat6
  if defined(Class["Tomcat::Package::v5-5"]) or defined(Class["Tomcat::v5-5"]) {
    $serverdotxml = "server.xml.tomcat55.erb"
  }

  if defined(Class["Tomcat::Package::v6"]) or defined(Class["Tomcat::v6"]) {
    $serverdotxml = "server.xml.tomcat6.erb"
  }

  if defined(Class["Tomcat::Package::v5-5"]) {
    $catalinahome = $operatingsystem ? {
      RedHat => "/usr/share/tomcat5",
      Debian => "/usr/share/tomcat5.5",
      Ubuntu => "/usr/share/tomcat5.5",
    }
  }

  if defined(Class["Tomcat::Package::v6"]) {
    $catalinahome = $operatingsystem ? {
      #TODO: RedHat => "/usr/share/tomcat6",
      Debian => "/usr/share/tomcat6",
      Ubuntu => "/usr/share/tomcat6",
    }
  }

  # In this case, we are using a non package-based tomcat.
  if ( ! $catalinahome ) {
    $catalinahome = "/opt/apache-tomcat"
  }

  # Define default JAVA_HOME used in tomcat.init.erb
  if $java_home == "" {
    case $operatingsystem {
      RedHat: {
        $javahome = "/usr/lib/jvm/java"
      }
      Debian,Ubuntu: {
        $javahome = "/usr"
      }
      default: {
        err("java_home not defined for '${operatingsystem}'.")
      }
    }
  } else {
    $javahome = $java_home
  }

  # Instance directories
  case $ensure {
    present: {
      file {
        # Nobody usually write there
        "${basedir}":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 550,
          before => Service["tomcat-${name}"],
          require => $group ? {
            "adm"   => undef,
            default => Group[$group],
          };
    
        "${basedir}/bin":
          ensure => directory,
          owner  => "root",
          group  => $group,
          mode   => 755,
          before => Service["tomcat-${name}"];
    
        # Developpers usually write there
        "${basedir}/conf":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => $conf_mode,
          before => Service["tomcat-${name}"];

        "${basedir}/lib":
          ensure => directory,
          owner  => "root",
          group  => $group,
          mode   => 2775,
          before => Service["tomcat-${name}"];

        "${basedir}/conf/server.xml":
          ensure => present,
          owner  => "tomcat",
          group  => $group,
          mode   => 460,
          content => template("tomcat/${serverdotxml}"),
          replace => false,
          before => Service["tomcat-${name}"];

        "${basedir}/conf/web.xml":
          ensure => present,
          owner  => "tomcat",
          group  => $group,
          mode   => 460,
          content => template("tomcat/web.xml.erb"),
          replace => false,
          before => Service["tomcat-${name}"];

        "${basedir}/webapps":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
    
        # Tomcat usually write there
        "${basedir}/logs":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/work":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/temp":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/private":
          ensure => directory,
          owner  => "tomcat",
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
          owner   => "tomcat",
          group   => $group,
          mode    => 0460,
          source  => "puppet:///tomcat/sample.war",
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

  # Default JVM options
  file {"${basedir}/bin/setenv.sh":
    ensure  => $ensure,
    content => template("tomcat/setenv.sh.erb"),
    owner  => "root",
    group  => $group,
    mode   => 750,
    before => Service["tomcat-${name}"],
  }

  # User customized JVM options
  file {"${basedir}/bin/setenv-local.sh":
    ensure  => $ensure,
    replace => $setenv_content ? {
      ""      => false,
      default => true,
    },
    content => $setenv_content ? {
      ""      => template("tomcat/setenv-local.sh.erb"),
      default => "# file managed by puppet\n${setenv_content}\n",
    },
    owner  => "tomcat",
    group  => $setenv_content ? {
      ""      => $group,
      default => "root",
    },
    mode   => 570,
    before => Service["tomcat-${name}"],
  }


  # Init and env scripts
  file {"/etc/init.d/tomcat-${name}":
    ensure  => $ensure,
    content => template("tomcat/tomcat.init.erb"),
    owner   => "root",
    mode    => "755",
    require => File["${basedir}/bin/setenv.sh"],
  }

  if defined(Class["Tomcat::Package::v5-5"]) or defined(Class["Tomcat::package::v6"]) {
    $servicerequire = Package["tomcat"]
  } else {
    $servicerequire = File["/opt/apache-tomcat"]
  }

  service {"tomcat-${name}":
    ensure  => $ensure ? {
      present => "running",
      absent  => "stopped",
    },
    enable  => $ensure ? {
      present => true,
      absent  => false,
    },
    require => [File["/etc/init.d/tomcat-${name}"], $servicerequire],
    pattern => "-Dcatalina.base=/srv/tomcat/${name}",
  }

  # Logrotate
  file {"/etc/logrotate.d/tomcat-${name}.conf":
    ensure => $ensure,
    content => template("tomcat/tomcat.logrotate.erb"),
  }
}
