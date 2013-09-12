require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

rhel5 = @parameters['RHEL5']
rhel6 = @parameters['RHEL6']

describe "tomcat::install::redhat" do
  context 'On RHEL5' do
    let (:facts) { {
      :osfamily                  => rhel5['osfamily'],
      :operatingsystem           => rhel5['operatingsystem'],
      :operatingsystemmajrelease => rhel5['operatingsystemmajrelease'],
      :lsbdistmajrelease         => rhel5['lsbdistmajrelease'],
    } }

    describe 'should contain symlink' do
      it {
        should contain_file('/usr/share/tomcat5/bin/catalina.sh').with({
          'ensure' => 'link',
          'target' => '/usr/bin/dtomcat',
        })
      }
    end
  end

  context 'On RHEL6' do
    let (:facts) { {
      :osfamily                  => rhel6['osfamily'],
      :operatingsystem           => rhel6['operatingsystem'],
      :operatingsystemmajrelease => rhel6['operatingsystemmajrelease'],
      :lsbdistmajrelease         => rhel6['lsbdistmajrelease'],
    } }

    describe 'should create classpath.sh' do
      it {
        should contain_file('/usr/share/tomcat/bin/setclasspath.sh').with({
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }
    end

    describe 'should create catalina.sh' do
      it {
        should contain_file('/usr/share/tomcat/bin/catalina.sh').with({
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }
    end

  end
end
