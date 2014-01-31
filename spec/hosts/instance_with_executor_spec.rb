require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

all = @parameters
rhel5 = all['RHEL5']
all.delete('RHEL5') # take only new OS — there's no connector support for tomcat5

all.each { |k, v|

  describe 'instance_with_executor' do

    let (:facts) {{
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
    }}

    describe "#{k} should create connector1" do
      it {
        should contain_tomcat__connector('connector1')
      }
    end

    describe "#{k} should create connector1executor1" do
      it {
        should contain_tomcat__executor('executor1')
      }
    end

    describe "#{k} tomcat::connector should use executor1" do
      it {
        should contain_concat_fragment('server.xml_instance1+02_executor_executor1').with_content(
          /<!ENTITY executor-executor1 SYSTEM "executor-executor1.xml">/
        )
        should contain_concat_fragment('server.xml_instance1+05_executor_executor1').with_content(
          /&executor-executor1;/
        )
      }
    end

    describe "#{k} tomcat::instance should use connector1" do
      it {
        should contain_concat_fragment('server.xml_instance1+03_connector_connector1').with_content(
          /<!ENTITY connector-connector1 SYSTEM "connector-connector1.xml">/
        )   
        should contain_concat_fragment('server.xml_instance1+06_connector_connector1').with_content(
          /&connector-connector1;/
        )
        #should contain_file('/srv/tomcat/instance1/conf/server.xml').with_content(
        #  /<!ENTITY connector-connector1 SYSTEM "connector-connector1.xml">/
        #)
      }
    end

  end
}
