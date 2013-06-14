require 'spec_helper'

describe 'tomcat', :type => :class do
  context "on a Redhat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
      }
    end
    it { should include_class('tomcat') }
    it { should include_class('tomcat::redhat') }
    it { should include_class('tomcat::package') }
    it { should contain_service('tomcat').with(
      'ensure'  => 'stopped',
      'enable'  => 'false',
      'require' => 'Package[tomcat]'
    ) }
    it { should contain_package('tomcat').with(
      'ensure' => 'present'
    ) }
    it { should include_class('tomcat::base') }
    it { should contain_user('tomcat').with(
      'ensure' => 'present',
      'system' => 'true'
    ) } 
  end
end
