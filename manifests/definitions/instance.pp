define tomcat::instance($ensure, $group="adm", $server_port="8005", $http_port="8080", $ajp_port="8009") {
  $basedir = "/srv/tomcat/${name}"

  if defined(File["/srv/tomcat"]) {
    debug "File[/srv/tomcat] already defined"
  } else {
    file {"/srv/tomcat":
      ensure => directory,
    }
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
          require => Group[$group];
    
        "${basedir}/bin":
          ensure => directory,
          owner  => root,
          group  => $group,
          mode   => 755;
    
        # Developpers usually write there
        "${basedir}/conf":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2570;

        "${basedir}/conf/server.xml":
          ensure => present,
          owner  => "tomcat",
          group  => $group,
          mode   => 460,
          content => template("tomcat/server.xml.erb"),
          replace => false;

        "${basedir}/conf/web.xml":
          ensure => present,
          owner  => "tomcat",
          group  => $group,
          mode   => 460,
          content => template("tomcat/web.xml.erb"),
          replace => false;

        "${basedir}/webapps":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770;
    
        # Tomcat usually write there
        "${basedir}/logs":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770;
        "${basedir}/work":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770;
        "${basedir}/temp":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770;
        "${basedir}/private":
          ensure => directory,
          owner  => tomcat,
          group  => $group,
          mode   => 2770;
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
