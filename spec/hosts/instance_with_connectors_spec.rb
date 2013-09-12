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
      :lsbdistmajrelease         => v['lsbdistmajrelease'],
    }}

    describe "#{k} should create connector1" do
      it {
        should contain_tomcat__connector('connector1')
      }
    end

    describe "#{k} tomcat::instance should use connector1" do
      it {
        should contain_file('/srv/tomcat/instance1/conf/server.xml').with_content(
          /<!ENTITY connector-connector1 SYSTEM "connector-connector1.xml">/
        )
      }
    end

  end
}
