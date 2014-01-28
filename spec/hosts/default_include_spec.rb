require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k, v|

  describe 'default_include' do

    let (:facts) {{
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
    }}

    describe "#{k}: should install #{v['tomcat_package']} package" do
      it {
        should contain_package(v['tomcat_package'])
      }
    end

    describe "#{k}: should install #{v['log4j']} and #{v['logging']}" do
      it {
        should contain_package(v['log4j'])
        should contain_package(v['logging'])
      }
    end

    describe "#{k}: should contain tomcat::connectors" do
      it {
        should contain_tomcat__connector('http-8080-instance1').with_ensure('present')
        should contain_tomcat__connector('ajp-8009-instance1').with_ensure('present')
      }
    end

    describe "#{k}: should have tomcat-instance1 server" do
      it {
        should contain_service('tomcat-instance1').with({
          'ensure' => 'running',
          'enable' => 'true',
        })
      }
    end

    describe "#{k}: should have tomcat-instance1 init-script" do
      it {
        should contain_file('/etc/init.d/tomcat-instance1').with({
          'ensure' => 'file',
          'mode'   => '0755',
          'owner'  => 'root',
        })

        should contain_file('/etc/init.d/tomcat-instance1').with_content(/CATALINA_HOME=\/usr\/share\/tomcat#{v['tomcat_version']}/)
        should contain_file('/etc/init.d/tomcat-instance1').with_content(/CATALINA_BASE=\/srv\/tomcat\/instance1/)
        should contain_file('/etc/init.d/tomcat-instance1').with_content(/JAVA_HOME=#{v['java_home']}/)
      }
    end

    describe "#{k}: should have tomcat-instance1 service" do
      it {
        should contain_service('tomcat-instance1').with({
          'ensure' => 'running',
          'enable' => true,
        })
      }
    end


  end
}
