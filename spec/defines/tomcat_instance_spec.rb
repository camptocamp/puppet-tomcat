require 'spec_helper'

describe 'tomcat::instance' do

  let (:title) {'fooBar'}

  let(:pre_condition) do
    "class { 'tomcat': }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/foo',
          :puppet_vardir => '/var/lib/puppet',
        })
      end

      context 'when using a wrong ensure value' do
        let (:params) {{
          :ensure => 'foobar',
        }}
        it 'should fail' do
          expect { 
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /validate_re\(\):/)
        end
      end

      context 'when using a wrong owner value' do
        let(:params) {{
          :owner => true
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /.+ is not a string/)
        end
      end

      context 'when using a wrong group value' do
        let(:params) {{
          :group => true
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /.+ is not a string/)
        end
      end

      context 'when using a wrong server_port value' do
        let(:params) {{
          :server_port => 'aaaa'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /validate_re\(\)/)
        end
      end

      context 'when using a wrong http_port value' do
        let(:params) {{
          :http_port => 'bbbb'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /validate_re\(\)/)
        end
      end

      context 'when using a wrong ajp_port value' do
        let(:params) {{
          :ajp_port => 'bbbb'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /validate_re\(\)/)
        end
      end

      context 'when using a wrong setenv value' do
        let(:params) {{
          :setenv => 'not_array'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /.* is not an Array/)
        end
      end

      context 'when using a wrong connector value' do
        let(:params) {{
          :connector => 'not_array'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /.+ is not an Array/)
        end
      end

      context 'when using a wrong executor value' do
        let(:params) {{
          :executor => 'not_array'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /.+ is not an Array/)
        end
      end

      context 'when using a wrong instance_basedir value' do
        let(:params) {{
          :instance_basedir => 'some/relative/path'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /.+ is not an absolute path/)
        end
      end

      context 'when using a wrong tomcat_version value' do
        let(:params) {{
          :tomcat_version => 'bbbb'
        }}
        it 'should fail' do
          expect {
            should contain_tomcat__instance('fooBar')
          }.to raise_error(Puppet::Error, /validate_re\(\)/)
        end
      end

      describe "should create /srv/tomcat/fooBar" do
        it {
          should contain_file("/srv/tomcat/fooBar").with({
            'ensure' => 'directory',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '0555',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/bin" do
        it {
          should contain_file("/srv/tomcat/fooBar/bin").with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'adm',
            'mode'   => '0755',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/conf" do
        it {
          should contain_file("/srv/tomcat/fooBar/conf").with({
            'ensure' => 'directory',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '2570',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/lib" do
        it {
          should contain_file("/srv/tomcat/fooBar/lib").with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'adm',
            'mode'   => '2775',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/private" do
        it {
          should contain_file("/srv/tomcat/fooBar/private").with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'adm',
            'mode'   => '2775',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/webapps" do
        it {
          should contain_file("/srv/tomcat/fooBar/webapps").with({
            'ensure' => 'directory',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '2770',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/logs" do
        it {
          should contain_file("/srv/tomcat/fooBar/logs").with({
            'ensure' => 'directory',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '2770',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/work" do
        it {
          should contain_file("/srv/tomcat/fooBar/work").with({
            'ensure' => 'directory',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '2770',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/temp" do
        it {
          should contain_file("/srv/tomcat/fooBar/temp").with({
            'ensure' => 'directory',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '2770',
          })
        }
      end

      describe "should create /srv/tomcat/fooBar/conf/server.xml" do
        if facts[:osfamily] == 'RedHat' and facts[:operatingsystemmajrelease].to_i == 5
          it {
            should contain_file("/srv/tomcat/fooBar/conf/server.xml").with({
              'ensure'  => 'file',
              'owner'   => 'tomcat',
              'group'   => 'adm',
              'mode'    => '0460',
              'source'  => nil,
            })
          }
        else
          it {
            should contain_concat("/srv/tomcat/fooBar/conf/server.xml").with({
              'ensure'  => 'present',
              'owner'   => 'tomcat',
              'group'   => 'adm',
              'mode'    => '0460',
            })
          }

        end
      end

      describe "should create bin/setenv.sh" do
        it {
          should contain_concat("/srv/tomcat/fooBar/bin/setenv.sh").with({
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'adm',
            'mode'    => '0754',
          })
        }
      end

      describe "should create bin/setenv-local.sh" do
        it {
          should contain_file("/srv/tomcat/fooBar/bin/setenv-local.sh").with({
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'adm',
            'mode'    => '0574',
          })
        }
      end

      describe "should have tomcat-fooBar server" do
        it {
          should contain_service('tomcat-fooBar').with({
            'ensure' => 'running',
            'enable' => 'true',
          })
        }
      end

      describe "should create init script" do
        it {
          case facts[:osfamily]
          when 'Debian'
            should contain_file('/etc/init.d/tomcat-fooBar').
              with_ensure('present').
              with_owner('root').
              with_mode('0755').
              with_content(/JAVA_HOME=\/usr/).
              with_content(%r{^export CATALINA_BASE=/srv/tomcat/fooBar})
          when 'RedHat'
            if facts[:operatingsystemmajrelease].to_i < 7
              if facts[:operatingsystem] == 'CentOS'
                should contain_file('/etc/init.d/tomcat-fooBar').
                  with_ensure('present').
                  with_owner('root').
                  with_mode('0755').
                  with_content(%r{JAVA_HOME=/etc/alternatives/jre}).
                  with_content(%r{^export CATALINA_BASE=/srv/tomcat/fooBar}).
                  with_content(/tomcat -c \"umask 0002;/)
              else
                should contain_file('/etc/init.d/tomcat-fooBar').
                  with_ensure('present').
                  with_owner('root').
                  with_mode('0755').
                  with_content(/JAVA_HOME=\/usr\/lib\/jvm\/java/).
                  with_content(%r{^export CATALINA_BASE=/srv/tomcat/fooBar}).
                  with_content(/tomcat -c \"umask 0002;/)
              end
            else
              should contain_file('/usr/lib/systemd/system/tomcat-fooBar.service').with({
                'ensure' => 'file',
                'owner'  => 'root',
                'mode'   => '0644',
                'content' => ".include /usr/lib/systemd/system/tomcat.service\n[Service]\nUMask=0002\nEnvironment=\"SERVICE_NAME=tomcat-fooBar\"\nEnvironmentFile=-/etc/sysconfig/tomcat-fooBar\n",
              })
            end
          end
        }
      end

      context 'add some env variables' do
        let(:params) {{
          :setenv => ['JAVA_XMX="512m"', 'JAVA_XX_MAXPERMSIZE="512m"']
        }}
        it {
          should contain_concat('/srv/tomcat/fooBar/bin/setenv.sh').with({
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'adm',
            'mode'    => '0754',
          })
          should contain_concat__fragment('setenv.sh_fooBar+01_header').with_content(/JAVA_XMX=\"512m\"/)
          should contain_concat__fragment('setenv.sh_fooBar+01_header').with_content(/JAVA_XX_MAXPERMSIZE=\"512m\"/)
        }
      end

      context 'enable sample' do
        let(:params) {{
          :sample => true
        }}
        it {
          should contain_file("/srv/tomcat/fooBar/webapps/sample.war").with({
            'ensure' => 'file',
            'owner'  => 'tomcat',
            'group'  => 'adm',
            'mode'   => '0460'
          })
        }
      end

      context 'ensure to absent' do
        let(:params) {{
          :ensure => 'absent'
        }}
        it {
          should contain_file("/srv/tomcat/fooBar").with({
            'ensure'  => 'absent',
            'recurse' => true,
            'force'   => true
          })
        }
      end
    end
  end
end
