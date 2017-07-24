## 2017-07-13 - Release 0.16.5

Add possibility to change owner and group of RHEL7 system config files.

## 2017-07-13 - Release 0.16.3

Add support for systemd limit per instance

## 2016-07-28 - Release 0.16.1

Fix unit tests (and deploy to puppetforge)

## 2016-07-28 - Release 0.16.0

Fix tomcat instance settings on RHEL 7 ($setenv is not deprecated anymore)

## 2015-09-23 - Release 0.15.0

Add java_opts params to tomcat::instance for setting JAVA_OPTS on RedHat7 only for the moment (deprecating $setenv)

## 2015-09-17 - Release 0.14.2

Fix: Service resource sometimes refresh before Exec systemd reload

## 2015-09-15 - Release 0.14.1

Fix for RHEL 7
Add Ubuntu 14.04 support
Fix acceptance tests

## 2015-08-21 - Release 0.14.0

Prevent puppet restarting tomcat when it shouldn't
Install make to build ruby-augeas

## 2015-08-21 - Release 0.13.9

Use docker for acceptance tests

## 2015-06-30 - Release 0.13.8

Fix unit tests

## 2015-06-26 - Release 0.13.7

Fix strict_variables activation with rspec-puppet 2.2

## 2015-05-28 - Release 0.13.6

Add beaker_spec_helper to Gemfile

## 2015-05-27 - Release 0.13.5

Fix unscoped variable in template

## 2015-05-26 - Release 0.13.4

Use random application order in nodeset

## 2015-05-26 - Release 0.13.3

add utopic & vivid nodesets

## 2015-05-25 - Release 0.13.2

Don't allow failure on Puppet 4

## 2015-05-19 - Release 0.13.1

Fix when using a server_xml_file

## 2015-05-19 - Release 0.13.0

Use puppetlabs-concat instead of theforeman-concat_native

## 2015-05-18 - Release 0.12.0

Add dynamic dependency between install and service

## 2015-05-15 - Release 0.11.2

Fix missing ownerships
Internal refactoring

## 2015-05-13 - Release 0.11.1

Add puppet-lint-file_source_rights-check gem

## 2015-05-13 - Release 0.11.0

Remove experimental implementation

## 2015-05-12 - Release 0.10.5

Don't pin beaker

## 2015-04-27 - Release 0.10.4

Add nodeset ubuntu-12.04-x86_64-openstack

## 2015-04-15 - Release 0.10.3

Use file() function instead of fileserver (much faster)
Fix for concat_native 1.4+
Requires concat_native 1.4+

## 2015-04-14 - Release 0.10.2

add a parameter catalina_base_mode that sets rights on catalina_base

## 2015-04-10 - Release 0.10.1

Fix init script when overriding JAVA_HOME in setenv-local.sh

## 2015-04-03 - Release 0.10.0

Add Debian 8 support
Add acceptance tests for debian6 and centos6 to travis matrix
Remove RedHat 5 support (may still work but untested)

## 2015-03-24 - Release 0.9.0

Support Debian Jessie (with tomcat7)
Add acceptance tests on Travis CI

## 2015-03-24 - Release 0.8.10

Update Gemfile

## 2015-03-13 - Release 0.8.9

Fix a bug with systemd service file

## 2015-03-11 - Release 0.8.8

Fix: Tomcat::Connector should refresh Service

## 2015-02-19 - Release 0.8.7

Fix for future parser

## 2015-02-18 - Release 0.8.6

Revert fix

## 2015-02-18 - Release 0.8.5

Fix future parser issue

## 2015-01-29 - Release 0.8.4

Don't use fakeroot for unit tests
Fix future parser issues
Use absolute names in class inclusions
Use undef instead of empty strings

## 2015-01-07 - Release 0.8.3

Fix unquoted strings in cases

## 2015-01-05 - Release 0.8.2

Add CHANGELOG.md
Fix license name in metadata.json
Simplify bundler cache in Travis CI
