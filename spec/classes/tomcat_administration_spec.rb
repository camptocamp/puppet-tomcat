require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::administration' do
    let (:facts) { {
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
      :sudoversion               => v['sudo_version'],
    } }

    describe 'should create a group' do
      it {
        should contain_group('tomcat-admin').with('system' => true)
      }
    end

    describe 'should create a sudo::conf' do
      it {
        should contain_sudo__conf('tomcat-administration').with_ensure('present')
      }
    end

  end
}
