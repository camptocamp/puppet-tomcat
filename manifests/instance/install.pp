define tomcat::instance::install(
  $catalina_base,
) {
  $catalina_logrotate = getparam(Tomcat::Instance[$title], 'catalina_logrotate')
  $conf_mode          = getparam(Tomcat::Instance[$title], 'conf_mode')
  $ensure             = getparam(Tomcat::Instance[$title], 'ensure')
  $group              = getparam(Tomcat::Instance[$title], 'group')
  $logs_mode          = getparam(Tomcat::Instance[$title], 'logs_mode')
  $owner              = getparam(Tomcat::Instance[$title], 'owner')
  $version            = getparam(Tomcat::Instance[$title], 'tomcat_version')
  $webapp_mode        = getparam(Tomcat::Instance[$title], 'webapp_mode')

  if defined(File[$tomcat::instance_basedir]) {
    debug "File[${tomcat::instance_basedir}] already defined"
  } else {
    file {$tomcat::instance_basedir:
      ensure => directory,
    }
  }

  case $ensure {
    present,installed,running,stopped: {

      if $::tomcat::distro_way and $::osfamily == 'Debian' {
        package { "tomcat${version}-user":
          ensure => present,
        }
        ->
        exec { "tomcat${version}-instance-create ${catalina_base}":
          creates => $catalina_base,
          path    => $::path,
          before  => File[$catalina_base],
        }

        # Debian's init script requires at least one policy file
        file { "${catalina_base}/conf/policy.d":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => '2770',
        }
        file { "${catalina_base}/conf/policy.d/empty.policy":
          ensure => file,
          owner  => $owner,
          group  => $group,
          mode   => '0644',
        }
      }

      if $owner == 'tomcat' {
        $dirmode  = $webapp_mode ? {
          ''      => '2770',
          default => $webapp_mode,
        }
        $confmode = $conf_mode ? {
          ''      => '2570',
          default => $conf_mode
        }
        $logsmode = $logs_mode ? {
          ''      => '2770',
          default => $logs_mode
        }
      } else {
        $dirmode  = $webapp_mode ? {
          ''      => '2775',
          default => $webapp_mode,
        }
        $confmode = $conf_mode ? {
          ''      => $dirmode,
          default => $conf_mode
        }
        $logsmode = $logs_mode ? {
          ''      => '2770',
          default => $logs_mode
        }
      }

      validate_re($dirmode, '^[0-9]+$')
      validate_re($confmode, '^[0-9]+$')
      validate_re($logsmode, '^[0-9]+$')

      file {
        # Nobody usually write there
        $catalina_base:
          ensure  => directory,
          owner   => $owner,
          group   => $group,
          mode    => '0555',
          ;

        "${catalina_base}/bin":
          ensure => directory,
          owner  => 'root',
          group  => $group,
          mode   => '0755',
          ;

        # Developpers usually write there
        "${catalina_base}/conf":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $confmode,
          ;

        "${catalina_base}/lib":
          ensure => directory,
          owner  => 'root',
          group  => $group,
          mode   => '2775',
          ;

        "${catalina_base}/private":
          ensure => directory,
          owner  => 'root',
          group  => $group,
          mode   => '2775',
          ;

        "${catalina_base}/README":
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template("${module_name}/README.erb");

        "${catalina_base}/webapps":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $dirmode,
          ;

        # Tomcat usually write there
        "${catalina_base}/logs":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $logsmode,
          ;

        "${catalina_base}/work":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => '2770',
          ;

        "${catalina_base}/temp":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => '2770',
          ;
      }

      if getparam(Tomcat::Instance[$title], 'sample') {

        # Deploy a sample "Hello World" webapp available at:
        # http://localhost:8080/sample/
        #
        file { "${catalina_base}/webapps/sample.war":
          ensure => present,
          owner  => $owner,
          group  => $group,
          mode   => '0460',
          source => "puppet:///modules/${module_name}/sample.war",
        }
      }
    }
    absent: {
      file { $catalina_base:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
    default: {
      fail "Unknown ensure value : ${ensure}"
    }
  }

  $present = $ensure ? {
    present   => 'file',
    installed => 'file',
    running   => 'file',
    stopped   => 'file',
    absent    => 'absent',
  }

  # Default rotation of catalina.out
  # Not managed by default
  # TODO: managed mode with more options ?
  if $catalina_logrotate {
    file{ "/etc/logrotate.d/catalina-${name}":
      ensure  => $present,
      replace => false,
      content => template( 'tomcat/logrotate.catalina.erb' ),
    }
  }

}
