# == Definition: tomcat::probe
#
# Download and deploy psi-probe, a fork of the popular lambda-probe.
#
# A webapp named "probe" is deployed in the tomcat instance of the same name than
# the definition.
#
# Parameters:
# - *name*: must be the same as the tomcat instance in which the webapp must
#   be installed into.
# - *ensure*: present/absent, defaults to present.
# - *version*: the version of psi-probe to use, defaults to 2.0.4.
#
# Example usage:
#
#   include tomcat::v6
#   tomcat::probe    { "foobar": ensure => present }
#   tomcat::instance { "foobar": http_port => 8080, ensure => running }
#
# It is (currently) left to the user to configure a mandatory username to access
# the web interface. This can be done for example this way:
#
#   cat << EOF > /srv/tomcat/foobar/conf/tomcat-users.xml
#   <tomcat-users>
#     <role rolename="probeuser" />
#     <role rolename="poweruser" />
#     <role rolename="poweruserplus" />
#     <user username="admin" password="t0psecret" roles="manager,admin" />
#   </tomcat-users>
#   EOF
#
# Following this example, you should be able to point your browser to
# http://localhost:8080/probe/
#
# See also: http://code.google.com/p/psi-probe/
#
define tomcat::probe($ensure='present', $version='2.0.4') {

  validate_re($ensure, ['present','absent'])

  $url="http://psi-probe.googlecode.com/files/probe-${version}.zip"

  $sha1sum = $version ? {
    '2.0.4' => '2207bbc4a45af7e3cff2dfbd9377848f1b807387',
  }

  archive { "psi-probe-${version}":
    url           => $url,
    digest_string => $sha1sum,
    digest_type   => 'sha1',
    extension     => 'zip',
    target        => "/usr/src/psi-probe-${version}",
    # hack to avoid the exec reexecuting always, as the zip file contains no
    # base directory.
    root_dir      => 'probe.war',
  }

  file { "/srv/tomcat/${name}/webapps/probe.war":
    ensure  => $ensure,
    source  => "file:///usr/src/psi-probe-${version}/probe.war",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Archive["psi-probe-${version}"],
    notify  => Service["tomcat-${name}"],
  }
}
