require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k, v|
  describe "tomcat::install" do
    let (:facts) { {
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbdistmajrelease         => v['lsbdistmajrelease'],
    } }

    describe "should install package for #{k}" do
      it {
        should contain_package("tomcat")
      }
    end

    describe 'should include tomcat::juli' do
      it {
        should include_class('tomcat::juli')
      }
    end

    describe 'should include tomcat::logging' do
      it {
        should include_class('tomcat::logging')
      }
    end
  end
}
