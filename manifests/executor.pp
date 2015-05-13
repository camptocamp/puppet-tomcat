# == Definition: tomcat::executor
#
# This definition will create an executor in a dedicated file
# included in server.xml with an XML entity inclusion.Have a
# look at http://tomcat.apache.org/tomcat-6.0-doc/config/executor.html
# for more details.
#
# Parameters:
# - *name*: the filename prefix
# - *ensure*: define if this file is present or absent
# - *instance*: the name of the instance
# - *owner*: the owner of this file (useful if manage=false)
# - *thread_priority*: (int) the thread priority for threads in the executor
# - *daemon*: whether the threads should be daemon threads or not
# - *name_prefix*: the prefix for each thread created by the executor
# - *max_threads*: (int) max number of active threads in this pool
# - *min_spare_threads*: (int) minimum number of threads always kept alive
# - *max_idle_time*: (int) number of milliseconds before an idle thread
#   shutsdown
# - *manage*: only add this file/executor if it isn't already present
#
# Requires:
# - one of the tomcat classes which installs tomcat binaries.
# - a resource tomcat::instance.
#
# Example usage:
#
#   tomcat::executor {"default":
#     ensure            => present,
#     instance          => "tomcat1",
#     max_threads       => 150,
#     min_spare_threads => 25,
#   }
#
#   tomcat::connector {"http-8080":
#     ensure   => present,
#     instance => "tomcat1",
#     owner    => "root",
#     group    => "tomcat-admin",
#     protocol => "HTTP/1.1",
#     port     => 8080,
#     executor => "default",
#     manage   => true,
#   }
#
#   tomcat::instance { "tomcat1":
#     ensure    => present,
#     group     => "tomcat-admin",
#     manage    => true,
#     executor  => ["default"],
#     connector => ["http-8080"]
#   }
#
define tomcat::executor(
  $instance,
  $ensure            = present,
  $owner             = 'tomcat',
  $group             = 'adm',
  $thread_priority   = false,
  $daemon            = true,
  $name_prefix       = false,
  $max_threads       = 200,
  $min_spare_threads = 25,
  $max_idle_time     = 60000,
  $manage            = false,
  $instance_basedir  = $tomcat::instance_basedir,
) {

  validate_absolute_path($instance_basedir)

  if $owner == 'tomcat' {
    $filemode = '0460'
  } else {
    $filemode = '0664'
  }

  validate_string($instance)
  validate_re($ensure, ['present', 'absent'])
  validate_string($owner)
  validate_string($group)
  validate_bool($daemon)
  # lint:ignore:only_variable_string
  validate_re("${max_threads}", '^[0-9]+$')
  validate_re("${min_spare_threads}", '^[0-9]+$')
  validate_re("${max_idle_time}", '^[0-9]+$')
  # lint:endignore
  validate_bool($manage)


  file {"${instance_basedir}/${instance}/conf/executor-${name}.xml":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $filemode,
    content => template('tomcat/executor.xml.erb'),
    replace => $manage,
  }

  if versioncmp($::tomcat::version, '5') != 0 {
    concat::fragment { "server.xml_${instance}+02_executor_${name}":
      target  => "${instance_basedir}/${instance}/conf/server.xml",
      content => "  <!ENTITY executor-${name} SYSTEM \"executor-${name}.xml\">\n",
      order   => '02',
    }

    concat::fragment { "server.xml_${instance}+05_executor_${name}":
      target  => "${instance_basedir}/${instance}/conf/server.xml",
      content => "    <!-- See conf/executor-${name}.xml for this executor's config. -->
      &executor-${name};\n",
      order   => '05',
    }
  }

}
