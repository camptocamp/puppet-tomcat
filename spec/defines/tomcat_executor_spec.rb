require 'spec_helper'

describe 'tomcat::executor' do
  let(:title) { 'executorBar' }

  let :pre_condition do
    "class { 'tomcat': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(concat_basedir: '/foo',
                    puppet_vardir: '/var/lib/puppet')
      end

      context 'when using a wrong ensure value' do
        let(:params) do
          {
            ensure: 'foobar',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\):})
        end
      end

      context 'when using a wrong owner value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            owner: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{.+ is not a string})
        end
      end

      context 'when using a wrong group value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            group: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{.+ is not a string})
        end
      end

      context 'when using a wrong daemon value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            daemon: 'foobar',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{.+ is not a boolean})
        end
      end

      context 'when using a wrong max_threads value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            max_threads: 'string',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      context 'when using a wrong min_spare_threads value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            min_spare_threads: 'string',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      context 'when using a wrong max_idle_time value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            max_idle_time: 'string',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      context 'when using a wrong manage value' do
        let(:params) do
          {
            ensure: 'present',
            instance: 'instance',
            instance_basedir: '/srv/tomcat',
            manage: 'bbbb',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__executor('executorBar')
          }.to raise_error(Puppet::Error, %r{.+ is not a boolean})
        end
      end

      let(:params) do
        {
          instance: 'instance1',
          instance_basedir: '/srv/tomcat',
        }
      end

      describe 'should create a file' do
        it {
          is_expected.to contain_file('/srv/tomcat/instance1/conf/executor-executorBar.xml').with('ensure' => 'present',
                                                                                                  'owner'   => 'tomcat',
                                                                                                  'group'   => 'adm',
                                                                                                  'mode'    => '0460',
                                                                                                  'replace' => false)
          is_expected.to contain_file('/srv/tomcat/instance1/conf/executor-executorBar.xml').with_content(%r{name="executorBar"})
        }
      end
    end
  end
end
