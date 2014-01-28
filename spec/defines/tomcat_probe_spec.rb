require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::probe' do
    let (:title) {'probeBar'}
    let (:facts) { {
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
    } }

    context 'when using a wrong ensure value' do
      let (:params) {{
        :ensure  => 'foobar',
        :version => '2.0.4',
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__instance('probeBar')
        }.to raise_error(Puppet::Error, /.*"foobar" does not match.*/)
      end
    end

    describe 'should create archive resource' do
      it {
        should contain_archive('psi-probe-2.0.4').with({
          'url'           => 'http://psi-probe.googlecode.com/files/probe-2.0.4.zip',
          'digest_string' => '2207bbc4a45af7e3cff2dfbd9377848f1b807387',
          'target'        => '/usr/src/psi-probe-2.0.4',
        })
      }
    end

    describe 'should create a file' do
      it {
        should contain_file('/srv/tomcat/probeBar/webapps/probe.war').with({
          'ensure' => 'present',
          'source' => 'file:///usr/src/psi-probe-2.0.4/probe.war',
          'notify' => 'Service[tomcat-probeBar]',
        })
      }
    end

  end
}
