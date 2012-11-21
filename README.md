Tomcat Puppet module
====================

**Manages Tomcat configuration.**

This module is provided by [Camptocamp](http://camptocamp.com/).

This module will install tomcat, either using you system's package
manager or from a compressed archive available on one of the
tomcat-mirrors.

This is done by including one of these classes:

 -   tomcat
 -   tomcat::source

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

Dependencies
------------

The Apache puppet module available at
[http://github.com/camptocamp/puppet-apache](http://github.com/camptocamp/puppet-apache)
is required if you want to make use of Apache integration.

The Archive puppet module available at
[http://github.com/camptocamp/puppet-archive](http://github.com/camptocamp/puppet-archive)
is required if you want to install tomcat from a compressed archive (it
uses archive).

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

    include tomcat

    tomcat::instance {"myapp":
      ensure    => present,
      http_port => "8080",
    }

If you want to install a specific tomcat version from a specific mirror:

    $tomcat_mirror = "http://archive.apache.org/dist/tomcat/"
    $tomcat_version = "6.0.32"
    include tomcat::source

Apache integration
------------------

Pre-requisites:

    include apache

    apache::module {"proxy_ajp":
      ensure  => present,
    }

    apache::vhost {"www.mycompany.com":
      ensure => present,
    }

Create a tomcat instance which is accessible via Apache using AJP on a
given virtualhost:

    include tomcat

    tomcat::instance {"myapp":
      ensure      => present,
      ajp_port    => "8000",
      http_port   => "",
    }

    apache::proxypass {"myapp":
      ensure   => present,
      location => "/myapp",
      vhost    => "www.mycompany.com",
      url      => "ajp://localhost:8000",
    }

Multiple instances
------------------

If you create multiple Tomcat instances, you must avoid port clash by
setting distinct ports for each instance:

    include tomcat

    tomcat::instance {"tomcat1":
      ensure      => present,
      server_port => "8005",
      http_port   => "8080",
      ajp_port    => "8009",
    }

    tomcat::instance {"tomcat2":
      ensure      => present,
      server_port => "8006",
      http_port   => "8081",
      ajp_port    => "8010",
    }

Create a tomcat instance with custom connectors
-----------------------------------------------

First you have to declare you connectors then they are added to the
tomcat-instance:

    include tomcat

    tomcat::connector{"http-8080":
      ensure   => present,
      instance => "tomcat1",
      protocol => "HTTP/1.1",
      port     => 8080,
      manage   => true,
    }

    tomcat::connector{"ajp-8081":
      ensure   => present
      instance => "tomcat1"
      protocol => "AJP/1.3",
      port     => 8081,
      manage   => true,
    }

    tomcat::instance {"tomcat1":
      ensure    => present,
      group     => "tomcat-admin",
      manage    => true,
      connector => ["http-8080","ajp-8081"],
    }
