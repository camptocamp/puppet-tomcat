Tomcat Puppet module
====================

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/camptocamp/tomcat.svg)](https://forge.puppetlabs.com/camptocamp/tomcat)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/camptocamp/tomcat.svg)](https://forge.puppetlabs.com/camptocamp/tomcat)
[![Build Status](https://img.shields.io/travis/camptocamp/puppet-tomcat/master.svg)](https://travis-ci.org/camptocamp/puppet-tomcat)
[![Gemnasium](https://img.shields.io/gemnasium/camptocamp/puppet-tomcat.svg)](https://gemnasium.com/camptocamp/puppet-tomcat)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

**Manages Tomcat configuration.**

This module is provided by [Camptocamp](http://camptocamp.com/).

This module will install tomcat, either using you system's package
manager or from a compressed archive available on one of the
tomcat-mirrors.

This is done by including the tomcat class for a package based setup
or declaring the class with the parameter sources => true for a source
based setup.

Instances
---------

You'll then be able to define one or more tomcat instances, where you
can drop your webapps in the ".war" format. This is done with the
`tomcat::instance` definition.

The idea is to have several independent tomcats running on the same
host, each of which can be restarted and managed independently. If one
of them happens to crash, it won't affect the other instances. The
drawback is that each tomcat instance starts it's own JVM, which
consumes memory.

This is implemented by having a shared `$CATALINA_HOME`, and each
instance having it's own `$CATALINA_BASE`. More details are found in
this document:
[http://tomcat.apache.org/tomcat-6.0-doc/RUNNING.txt](http://tomcat.apache.org/tomcat-6.0-doc/RUNNING.txt)

Logging
-------

To offer more flexibility and avoid having to restart tomcat each time
catalina.out is rotated, tomcat is configured to send it's log messages
to log4j. By default log4j is configured to send all log messages from
all instances to /var/log/tomcat/tomcat.log.

This can easily be overridden on an instance base by creating a custom
log4j.properties file and setting the `common.loader` path to point to
it, by editing `/srv/tomcat/<name>/conf/catalina.properties`.

Defaults
--------

By default a new tomcat instance create by a tomcat::instance resource
will listen on the following ports:

 -   8080 HTTP
 -   8005 Control
 -   8009 AJP

You should override these defaults by setting attributes `server_port`,
`http_port` and `ajp_port`.

Limitations
-----------

 -   there is no way to automatically manage webapps (`\*.war` files).
 -   the initscript calls catalina.sh instead of using jsvc. This
     prevents tomcat from listening on ports < 1024.

Examples
--------

**Simple standalone instance:**

Create a standalone tomcat instance whose HTTP server listen on port
8080:

    Exec {
      path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin',
    }

    include tomcat

    tomcat::instance {'myapp':
      ensure    => present,
      http_port => '8080',
    }

If you want to install a specific tomcat version from a specific mirror:

    class { 'tomcat':
      version     => 6,
      sources     => true,
      sources_src => 'http://archive.apache.org/dist/tomcat/',
    }

Apache integration
------------------

Pre-requisites:

    include apache_c2c

    apache_c2c::module {'proxy_ajp':
      ensure  => present,
    }

    apache_c2c::vhost {'www.mycompany.com':
      ensure => present,
    }

Create a tomcat instance which is accessible via Apache using AJP on a
given virtualhost:

    include tomcat

    tomcat::instance {'myapp':
      ensure      => present,
      ajp_port    => '8000'
    }

    apache_c2c::proxypass {'myapp':
      ensure   => present,
      location => '/myapp',
      vhost    => 'www.mycompany.com',
      url      => 'ajp://localhost:8000',
    }

Multiple instances
------------------

If you create multiple Tomcat instances, you must avoid port clash by
setting distinct ports for each instance:

    include tomcat

    tomcat::instance {'tomcat1':
      ensure      => present,
      server_port => '8005',
      http_port   => '8080',
      ajp_port    => '8009',
    }

    tomcat::instance {'tomcat2':
      ensure      => present,
      server_port => '8006',
      http_port   => '8081',
      ajp_port    => '8010',
    }

Create a tomcat instance with custom connectors
-----------------------------------------------

First you have to declare you connectors then they are added to the
tomcat-instance:

    include tomcat

    tomcat::connector{'http-8080':
      ensure   => present,
      instance => 'tomcat1',
      protocol => 'HTTP/1.1',
      port     => 8080,
      manage   => true,
    }

    tomcat::connector{'ajp-8081':
      ensure   => present
      instance => 'tomcat1'
      protocol => 'AJP/1.3',
      port     => 8081,
      manage   => true,
    }

    tomcat::instance {'tomcat1':
      ensure    => present,
      group     => 'tomcat-admin',
      manage    => true,
      connector => ['http-8080','ajp-8081'],
    }
