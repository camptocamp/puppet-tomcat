====================
Tomcat Puppet module
====================

This module is provided to you by Camptocamp_.

.. _Camptocamp: http://camptocamp.com/

------------
Dependencies
------------

The Apache puppet module available at
http://github.com/camptocamp/puppet-apache is required if you want to make use
of Apache integration.

The Common puppet module available at
http://github.com/camptocamp/puppet-common  is required for tomcat installation
(it uses common::archive::tar-gz)

--------
Defaults
--------

By default a new tomcat instance create by a tomcat::instance resource will
listen on the following ports:

* 8080 HTTP
* 8005 Control
* 8009 AJP

You should override these defaults by setting attributes server_port,
http_port and ajp_port.

--------
Examples
--------

Simple standalone instance
--------------------------

Create a standalone tomcat instance whose HTTP server listen on port 8080::

  tomcat::instance {"myapp":
    ensure    => present,
    http_port => "8080",
  }

Apache integration
------------------

Pre-requisites::

  apache::module {"proxy_ajp":
    ensure  => present,
  }

  apache::vhost {"www.mycompany.com":
    ensure => present,
  }

Create a tomcat instance which is accessible via Apache using AJP on a given
virtualhost::

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

If you create multiple Tomcat instances, you must avoid port clash by setting
distinct ports for each instance::

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
