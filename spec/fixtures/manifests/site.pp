$concat_basedir = '/var/lib/puppet/concat'

node default {
}
node default_include {
  class {'::tomcat': } ->
  tomcat::instance {'instance1':
  }
}
node instance_with_connectors {
  include ::tomcat
  ::tomcat::connector {'connector1':
    ensure   => present,
    instance => 'instance2',
    protocol => 'HTTP/1.1',
    port     => 8110,
    manage   => true,
  }
  ::tomcat::instance {'instance2':
    connector => ['connector1'],
  }
}
