require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k, v|

  describe 'managed_instance' do

    let (:facts) {{
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
    }}

    describe "#{k}: should contain tomcat::connectors" do
      it {
        should contain_tomcat__connector('http-8080-instance1').with({
          'ensure' => 'present',
          'manage' => true,
        })
        should contain_tomcat__connector('ajp-8009-instance1').with({
          'ensure' => 'present',
          'manage' => 'true',
        })
      }
    end

    describe "#{k}: connector files should be managed" do
      it {
        should contain_file('/srv/tomcat/instance1/conf/connector-http-8080-instance1.xml').with({
          'replace' => true,
        })
        should contain_file('/srv/tomcat/instance1/conf/connector-ajp-8009-instance1.xml').with({
          'replace' => true,
        })
      }
    end

    describe "#{k}: server.xml should be managed" do
      it {
        should contain_file('/srv/tomcat/instance1/conf/server.xml').with({
          'replace' => true,
        })
      }
    end


  end
}
