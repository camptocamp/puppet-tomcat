require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k, v|

  describe 'default' do

    let (:facts) {{
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbdistmajrelease         => v['lsbdistmajrelease'],
    }}

    describe "should install #{v['tomcat_package']} package" do
      it {
        should contain_package(v['tomcat_package'])
      }
    end

    describe "should install #{v['log4j']} and #{v['logging']}" do
      it {
        should contain_package(v['log4j'])
        should contain_package(v['logging'])
      }
    end

    describe "should contain tomcat::connectors" do
      it {
        should contain_tomcat__connector('http-8080-instance1').with_ensure('present')
        should contain_tomcat__connector('ajp-8009-instance1').with_ensure('present')
      }
    end

    describe "should have tomcat-instance1 server" do
      it {
        should contain_service('tomcat-instance1').with({
          'ensure' => 'running',
          'enable' => 'true',
        })
      }
    end


  end
}
