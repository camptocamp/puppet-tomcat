$concat_basedir = '/var/lib/puppet/concat'

node default {
}
node default_include {
  class {'::tomcat': } ->
  tomcat::instance {'instance1':
  }
}
node managed_instance {
  class {'::tomcat': } ->
  tomcat::instance {'instance1':
    manage => true,
  }
}
node instance_with_connectors {
  include ::tomcat
  ::tomcat::connector {'connector1':
    ensure   => present,
    instance => 'instance1',
    protocol => 'HTTP/1.1',
    port     => 8110,
    manage   => true,
  }
  ::tomcat::instance {'instance1':
    connector => ['connector1'],
  }
}
node instance_with_executor {
  include ::tomcat
  ::tomcat::executor {'executor1':
    instance => 'instance1',
  }
  ::tomcat::connector {'connector1':
    ensure   => present,
    instance => 'instance1',
    protocol => 'HTTP/1.1',
    port     => 8110,
    manage   => true,
  }
  ::tomcat::instance {'instance1':
    connector => ['connector1'],
    executor  => ['executor1'],
  }
}
