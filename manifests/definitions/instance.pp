define tomcat::instance($ensure="present",
                        $group="adm",
                        $server_port="8005",
                        $http_port="8080",
                        $http_address=false,
                        $ajp_port="8009",
                        $ajp_address=false,
                        $java_home="") {
  $basedir = "/srv/tomcat/${name}"

  if defined(File["/srv/tomcat"]) {
    debug "File[/srv/tomcat] already defined"
  } else {
    file {"/srv/tomcat":
      ensure => directory,
    }
  }

  # default server.xml is slightly different when using packages
  if defined(Class["Tomcat::Package"]) {
    case $operatingsystem {

      RedHat: {
        $serverdotxml = "server.xml.redhat.erb"
        $catalinahome = "/usr/share/tomcat5"
      }
      default: {
        err("operating system '${operatingsystem}' not defined.")
      }
    }

  } else {
    $serverdotxml = "server.xml.default.erb"
    $catalinahome = "/opt/apache-tomcat"
  }

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
          owner  => tomcat,
          group  => $group,
          mode   => 550,
          before => Service["tomcat-${name}"],
          require => Group[$group];
    
        "${basedir}/bin":
          ensure => directory,
          owner  => root,
          group  => $group,
          mode   => 755,
          before => Service["tomcat-${name}"];
    
        # Developpers usually write there
        "${basedir}/conf":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2570,
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
          owner  => tomcat,
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
    
        # Tomcat usually write there
        "${basedir}/logs":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/work":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/temp":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/private":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
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
    group  => "root",
    mode   => 570,
  }

  # User customized JVM options
  file {"${basedir}/bin/setenv-local.sh":
    ensure  => $ensure,
    replace => false,
    content => template("tomcat/setenv-local.sh.erb"),
    owner  => tomcat,
    group  => $group,
    mode   => 570,
  }


  # Init and env scripts
  file {"/etc/init.d/tomcat-${name}":
    ensure  => $ensure,
    content => template("tomcat/tomcat.init.erb"),
    owner   => "root",
    mode    => "755",
    require => File["${basedir}/bin/setenv.sh"],
  }

  service {"tomcat-${name}":
    ensure  => running,
    enable  => true,
    require => File["/etc/init.d/tomcat-${name}"],
    pattern => "-Dcatalina.base=/srv/tomcat/${name}",
  }

  # Logrotate
  file {"/etc/logrotate.d/tomcat-${name}.conf":
    ensure => present,
    content => template("tomcat/tomcate.logrotate.erb"),
  }
}
