require 'spec_helper'

describe 'tomcat::connector' do
  let (:title) { 'ConnectBar' }

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
        let (:params) do
          {
            ensure: 'foobar',
            instance: 'instance1',
            port: '8422',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{validate_re\(\):})
        end
      end

      context 'when using a wrong port value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: 'aaa',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{validate_re\(\):})
        end
      end

      context 'when using a wrong instance value' do
        let (:params) do
          {
            ensure: 'present',
            instance: true,
            port: '8442',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{.+ is not a string})
        end
      end

      context 'when using a wrong owner value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            owner: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{.+ is not a string})
        end
      end

      context 'when using a wrong group value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            group: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{.+ is not a string})
        end
      end

      context 'when using a wrong connection_timeout value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            connection_timeout: 'bbbb',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{validate_re\(\)})
        end
      end

      context 'when using a wrong redirect_port value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            redirect_port: 'bbbb',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{validate_re\(\)})
        end
      end

      context 'when using a wrong options value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            options: 'not_array',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{.+ is not an Array})
        end
      end

      context 'when using a wrong manage value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            manage: 'bibi',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{.+ is not a boolean})
        end
      end

      context 'when using a wrong instance_basedir value' do
        let (:params) do
          {
            ensure: 'present',
            instance: 'instance1',
            port: '8442',
            instance_basedir: 'some/relative/path',
          }
        end

        it 'fails' do
          expect {
            is_expected.to compile.with_all_deps
          }.to raise_error(%r{.+ is not an absolute path})
        end
      end

      context 'with params' do
        let(:params) do
          {
            instance: 'instance1',
            port: '8442',
            instance_basedir: '/srv/tomcat',
          }
        end
        let(:pre_condition) do
          "class { 'tomcat': }
          tomcat::instance { 'instance1': }"
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('connector_ConnectBar+01').with_content(%r{port="8442"})
          is_expected.to contain_concat__fragment('connector_ConnectBar+99').with_content(/protocol="HTTP\/1.1"/)
          is_expected.to contain_concat('/srv/tomcat/instance1/conf/connector-ConnectBar.xml').with('ensure' => 'present',
                                                                                                    'owner'   => 'tomcat',
                                                                                                    'group'   => 'adm',
                                                                                                    'mode'    => '0460',
                                                                                                    'replace' => false)
        }
        it {
          is_expected.to contain_concat__fragment('server.xml_instance1+03_connector_ConnectBar')
          is_expected.to contain_concat__fragment('server.xml_instance1+06_connector_ConnectBar')
        }
      end

      context 'when using a server.xml file' do
        let(:params) do
          {
            instance: 'instance1',
            port: '8442',
            instance_basedir: '/srv/tomcat',
          }
        end
        let(:pre_condition) do
          "class { 'tomcat': }
          tomcat::instance { 'instance1':
            server_xml_file => 'file:///foo/bar',
          }"
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_concat__fragment('connector_ConnectBar+01').with_content(%r{port="8442"})
          is_expected.to contain_concat__fragment('connector_ConnectBar+99').with_content(/protocol="HTTP\/1.1"/)
          is_expected.to contain_concat('/srv/tomcat/instance1/conf/connector-ConnectBar.xml').with('ensure' => 'present',
                                                                                                    'owner'   => 'tomcat',
                                                                                                    'group'   => 'adm',
                                                                                                    'mode'    => '0460',
                                                                                                    'replace' => false)
        }
        it {
          is_expected.not_to contain_concat__fragment('server.xml_instance1+03_connector_ConnectBar')
          is_expected.not_to contain_concat__fragment('server.xml_instance1+06_connector_ConnectBar')
        }
      end
    end
  end
end
