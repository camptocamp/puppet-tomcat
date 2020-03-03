require 'spec_helper'

describe 'tomcat::instance' do
  let(:title) { 'fooBar' }

  let(:pre_condition) do
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
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\):})
        end
      end

      context 'when using a wrong owner value' do
        let(:params) do
          {
            owner: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{.+ is not a string})
        end
      end

      context 'when using a wrong group value' do
        let(:params) do
          {
            group: true,
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{.+ is not a string})
        end
      end

      context 'when using a wrong server_port value' do
        let(:params) do
          {
            server_port: 'aaaa',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      context 'when using a wrong http_port value' do
        let(:params) do
          {
            http_port: 'bbbb',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      context 'when using a wrong ajp_port value' do
        let(:params) do
          {
            ajp_port: 'bbbb',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      context 'when using a wrong setenv value' do
        let(:params) do
          {
            setenv: 'not_array',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{.* is not an Array})
        end
      end

      context 'when using a wrong connector value' do
        let(:params) do
          {
            connector: 'not_array',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{.+ is not an Array})
        end
      end

      context 'when using a wrong executor value' do
        let(:params) do
          {
            executor: 'not_array',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{.+ is not an Array})
        end
      end

      context 'when using a wrong instance_basedir value' do
        let(:params) do
          {
            instance_basedir: 'some/relative/path',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{.+ is not an absolute path})
        end
      end

      context 'when using a wrong tomcat_version value' do
        let(:params) do
          {
            tomcat_version: 'bbbb',
          }
        end

        it 'fails' do
          expect {
            is_expected.to contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, %r{validate_re\(\)})
        end
      end

      describe 'should create /srv/tomcat/fooBar' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar').with('ensure' => 'directory',
                                                                 'owner'  => 'tomcat',
                                                                 'group'  => 'adm',
                                                                 'mode'   => '0555')
        }
      end

      describe 'should create /srv/tomcat/fooBar/bin' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/bin').with('ensure' => 'directory',
                                                                     'owner'  => 'root',
                                                                     'group'  => 'adm',
                                                                     'mode'   => '0755')
        }
      end

      describe 'should create /srv/tomcat/fooBar/conf' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/conf').with('ensure' => 'directory',
                                                                      'owner'  => 'tomcat',
                                                                      'group'  => 'adm',
                                                                      'mode'   => '2570')
        }
      end

      describe 'should create /srv/tomcat/fooBar/lib' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/lib').with('ensure' => 'directory',
                                                                     'owner'  => 'root',
                                                                     'group'  => 'adm',
                                                                     'mode'   => '2775')
        }
      end

      describe 'should create /srv/tomcat/fooBar/private' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/private').with('ensure' => 'directory',
                                                                         'owner'  => 'root',
                                                                         'group'  => 'adm',
                                                                         'mode'   => '2775')
        }
      end

      describe 'should create /srv/tomcat/fooBar/webapps' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/webapps').with('ensure' => 'directory',
                                                                         'owner'  => 'tomcat',
                                                                         'group'  => 'adm',
                                                                         'mode'   => '2770')
        }
      end

      describe 'should create /srv/tomcat/fooBar/logs' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/logs').with('ensure' => 'directory',
                                                                      'owner'  => 'tomcat',
                                                                      'group'  => 'adm',
                                                                      'mode'   => '2770')
        }
      end

      describe 'should create /srv/tomcat/fooBar/work' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/work').with('ensure' => 'directory',
                                                                      'owner'  => 'tomcat',
                                                                      'group'  => 'adm',
                                                                      'mode'   => '2770')
        }
      end

      describe 'should create /srv/tomcat/fooBar/temp' do
        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/temp').with('ensure' => 'directory',
                                                                      'owner'  => 'tomcat',
                                                                      'group'  => 'adm',
                                                                      'mode'   => '2770')
        }
      end

      describe 'should create /srv/tomcat/fooBar/conf/server.xml' do
        if facts[:osfamily] == 'RedHat' && facts[:operatingsystemmajrelease].to_i == 5
          it {
            is_expected.to contain_file('/srv/tomcat/fooBar/conf/server.xml').with('ensure' => 'file',
                                                                                   'owner'   => 'tomcat',
                                                                                   'group'   => 'adm',
                                                                                   'mode'    => '0460',
                                                                                   'source'  => nil)
          }
        else
          it {
            is_expected.to contain_concat('/srv/tomcat/fooBar/conf/server.xml').with('ensure' => 'present',
                                                                                     'owner'   => 'tomcat',
                                                                                     'group'   => 'adm',
                                                                                     'mode'    => '0460')
          }

        end
      end

      if facts[:osfamily] != 'RedHat' || facts[:operatingsystemmajrelease].to_i < 7
        describe 'should create bin/setenv.sh' do
          it {
            is_expected.to contain_concat('/srv/tomcat/fooBar/bin/setenv.sh').with('ensure' => 'present',
                                                                                   'owner'   => 'root',
                                                                                   'group'   => 'adm',
                                                                                   'mode'    => '0754')
          }
        end

        describe 'should create bin/setenv-local.sh' do
          it {
            is_expected.to contain_file('/srv/tomcat/fooBar/bin/setenv-local.sh').with('ensure' => 'present',
                                                                                       'owner'   => 'root',
                                                                                       'group'   => 'adm',
                                                                                       'mode'    => '0574')
          }
        end
      end

      describe 'should have tomcat-fooBar server' do
        it {
          is_expected.to contain_service('tomcat-fooBar').with('ensure' => 'running',
                                                               'enable' => 'true')
        }
      end

      describe 'should create init script' do
        it {
          case facts[:osfamily]
          when 'Debian'
            is_expected.to contain_file('/etc/init.d/tomcat-fooBar')
              .with_ensure('present')
              .with_owner('root')
              .with_mode('0755')
              .with_content(%r{JAVA_HOME=/usr})
              .with_content(%r{^export CATALINA_BASE=/srv/tomcat/fooBar})
          when 'RedHat'
            if facts[:operatingsystemmajrelease].to_i < 7
              if facts[:operatingsystem] == 'CentOS'
                is_expected.to contain_file('/etc/init.d/tomcat-fooBar')
                  .with_ensure('present')
                  .with_owner('root')
                  .with_mode('0755')
                  .with_content(%r{JAVA_HOME=/etc/alternatives/jre})
                  .with_content(%r{^export CATALINA_BASE=/srv/tomcat/fooBar})
                  .with_content(%r{tomcat -c \"umask 0002;})
              else
                is_expected.to contain_file('/etc/init.d/tomcat-fooBar')
                  .with_ensure('present')
                  .with_owner('root')
                  .with_mode('0755')
                  .with_content(%r{JAVA_HOME=/usr/lib/jvm/java})
                  .with_content(%r{^export CATALINA_BASE=/srv/tomcat/fooBar})
                  .with_content(%r{tomcat -c \"umask 0002;})
              end
            else
              is_expected.to contain_file('/usr/lib/systemd/system/tomcat-fooBar.service')
                .with(
                  'ensure' => 'file',
                  'owner'  => 'root',
                  'mode'   => '0644',
                  'content' => <<~EOF
                  .include /usr/lib/systemd/system/tomcat.service
                  [Service]
                  UMask=0002
                  LimitNOFILE=4096
                  Environment="SERVICE_NAME=tomcat-fooBar"
                  EnvironmentFile=-/etc/sysconfig/tomcat-fooBar
                  EOF
                )
            end
          end
        }
      end

      context 'add some env variables' do
        let(:params) do
          {
            setenv: ['JAVA_XMX="512m"', 'JAVA_XX_MAXPERMSIZE="512m"'],
          }
        end

        it {
          if facts[:osfamily] != 'RedHat' || facts[:operatingsystemmajrelease].to_i < 7
            is_expected.to contain_concat('/srv/tomcat/fooBar/bin/setenv.sh').with('ensure' => 'present',
                                                                                   'owner'   => 'root',
                                                                                   'group'   => 'adm',
                                                                                   'mode'    => '0754')
            is_expected.to contain_concat__fragment('setenv.sh_fooBar+01_header').with_content(%r{JAVA_XMX=\"512m\"})
            is_expected.to contain_concat__fragment('setenv.sh_fooBar+01_header').with_content(%r{JAVA_XX_MAXPERMSIZE=\"512m\"})
          else
            is_expected.to contain_shellvar('JAVA_XMX_fooBar').with('target' => '/etc/sysconfig/tomcat-fooBar',
                                                                    'variable' => 'JAVA_XMX',
                                                                    'value'    => '512m')
            is_expected.to contain_shellvar('JAVA_XX_MAXPERMSIZE_fooBar').with('target' => '/etc/sysconfig/tomcat-fooBar',
                                                                               'variable' => 'JAVA_XX_MAXPERMSIZE',
                                                                               'value'    => '512m')
          end
        }
      end

      context 'enable sample' do
        let(:params) do
          {
            sample: true,
          }
        end

        it {
          is_expected.to contain_file('/srv/tomcat/fooBar/webapps/sample.war').with('ensure' => 'file',
                                                                                    'owner'  => 'tomcat',
                                                                                    'group'  => 'adm',
                                                                                    'mode'   => '0460')
        }
      end

      context 'ensure to absent' do
        let(:params) do
          {
            ensure: 'absent',
          }
        end

        it {
          is_expected.to contain_file('/srv/tomcat/fooBar').with('ensure' => 'absent',
                                                                 'recurse' => true,
                                                                 'force'   => true)
        }
      end
    end
  end
end
