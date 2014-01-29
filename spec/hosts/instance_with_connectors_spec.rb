require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

all = @parameters
rhel5 = all['RHEL5']
all.delete('RHEL5') # take only new OS — there's no connector support for tomcat5

all.each { |k, v|

  describe 'instance_with_connectors' do

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

    describe "#{k} tomcat::instance should use connector1" do
      it {
        should contain_concat_fragment('server.xml_instance1+03_connector_connector1').with_content(
          /<!ENTITY connector-connector1 SYSTEM "connector-connector1.xml">/
        )
        should contain_concat_fragment('server.xml_instance1+06_connector_connector1').with_content(
          /&connector-connector1;/
        )
      }
    end

  end
}
