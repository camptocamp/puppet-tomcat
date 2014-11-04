# == Definition: tomcat::ulimit
#
# Helper definition which helps allocate more/less resources to the tomcat user,
# using PAM. See limits.conf(5) and pam_limits(8) for more details.
#
# Parameters:
#
# - *name*: the name of the limit to change (instance name).
# - *value*: the value to set for this limit.
#
# Example usage:
#
#   include tomcat
#   tomcat::ulimit { "nofile": value => 16384 }
#
# Better way:
#   class {'tomcat':
#     ulimits => {
#       'nofile': value => 16384,
#       'nproc':  value => 200,
#       ...
#       }
#   }
#
define tomcat::ulimit ($value) {

  augeas { "set tomcat ${name} ulimit":
    incl    => '/etc/security/limits.conf',
    lens    => 'Limits.lns',
    changes => [
      'set "domain[last()]" tomcat',
      'set "domain[.=\'tomcat\']/type" -',
      "set \"domain[.='tomcat']/item\" ${name}",
      "set \"domain[.='tomcat']/value\" ${value}",
      ],
    onlyif  => "match domain[.='tomcat'][type='-'][item='${name}'][value='${value}'] size == 0",
    before  => Class['tomcat::user'],
  }

}
