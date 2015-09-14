require 'spec_helper'

describe 'tomcat' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'should include basic classes' do
        it {
          should contain_class('tomcat::install')
          should contain_class('tomcat::user')
        }
      end

      describe 'should install tomcat package' do
        case facts[:osfamily]
        when 'Debian'
          case facts[:lsbdistcodename]
          when 'jessie'
            it { should contain_package('tomcat').with_name('tomcat8') }
          when 'trusty'
            it { should contain_package('tomcat').with_name('tomcat7') }
          else
            it { should contain_package('tomcat').with_name('tomcat6') }
          end
        when 'RedHat'
          case facts[:operatingsystemmajrelease]
          when '5'
            it { should contain_package('tomcat').with_name('tomcat5') }
          when '6'
            it { should contain_package('tomcat').with_name('tomcat6') }
          else
            it { should contain_package('tomcat').with_name('tomcat') }
          end
        end
      end

      describe 'should include tomcat::logging and tomcat::juli' do
        if ! (facts[:osfamily] == 'RedHat' and facts[:operatingsystemmajrelease].to_i > 6)
          it {
            should contain_class('tomcat::logging')
            should contain_class('tomcat::juli')
          }
        end
      end

      describe 'should install log4j and logging' do
        case facts[:osfamily]
        when 'Debian'
          it {
            should contain_package('liblog4j1.2-java')
            should contain_package('libcommons-logging-java')
          }
        when 'RedHat'
          if facts[:operatingsystemmajrelease].to_i < 7
            it {
              should contain_package('log4j')
              should contain_package('jakarta-commons-logging')
            }
          end
        end
      end

      describe 'should create tomcat user' do
        it {
          should contain_user('tomcat').with('system' => true)
        }
      end

      describe 'should deactivate default tomcat service' do
        case facts[:osfamily]
        when 'Debian'
          case facts[:lsbdistcodename]
          when 'jessie'
            it {
              should contain_service('tomcat').with({
                'ensure' => 'stopped',
                'name'   => 'tomcat8',
                'enable' => false,
              })

              should contain_file('/etc/init.d/tomcat8').with({
                'ensure' => 'file',
                'mode'   => '0644',
              })
            }
          when 'trusty'
            it {
              should contain_service('tomcat').with({
                'ensure' => 'stopped',
                'name'   => 'tomcat7',
                'enable' => false,
              })

              should contain_file('/etc/init.d/tomcat7').with({
                'ensure' => 'file',
                'mode'   => '0644',
              })
            }
          else
            it {
              should contain_service('tomcat').with({
                'ensure' => 'stopped',
                'name'   => 'tomcat6',
                'enable' => false,
              })

              should contain_file('/etc/init.d/tomcat6').with({
                'ensure' => 'file',
                'mode'   => '0644',
              })
            }
          end
        when 'RedHat'
          case facts[:operatingsystemmajrelease]
          when '5'
            it {
              should contain_service('tomcat').with({
                'ensure' => 'stopped',
                'name'   => 'tomcat5',
                'enable' => false,
              })
              should contain_file('/etc/init.d/tomcat5').with({
                'ensure' => 'file',
                'mode'   => '0644',
              })
            }
          when '6'
            it {
              should contain_service('tomcat').with({
                'ensure' => 'stopped',
                'name'   => 'tomcat6',
                'enable' => false,
              })
              should contain_file('/etc/init.d/tomcat6').with({
                'ensure' => 'file',
                'mode'   => '0644',
              })
            }
          else
            it {
              should contain_service('tomcat').with({
                'ensure' => 'stopped',
                'name'   => 'tomcat',
                'enable' => false,
              })
            }
          end
        end
      end

      {
        '5' => '5.5.27',
        '6' => '6.0.26',
        '7' => '7.0.42',
      }.each { |version, fullversion|
        context "install tomcat#{fullversion} from sources" do
          let(:params) {{
            :sources => true,
            :version => version,
          }}
          describe 'should include tomcat::source' do
            it {
              should contain_class('tomcat::source')
            }
          end
          describe 'should download tomcat' do
            it {
              should contain_archive("apache-tomcat-#{fullversion}").with({
                'url' => /tomcat-#{version}\/v#{fullversion}\/bin/,
              })
            }
          end
          describe 'should create tomcat home' do
            it {
              should contain_file("/opt/apache-tomcat-#{fullversion}").with_ensure('directory')
            }
          end
          describe 'should create symlink' do
            it {
              should contain_file('/opt/apache-tomcat').with({
                'ensure'  => 'link',
                'target'  => "/opt/apache-tomcat-#{fullversion}",
              })
            }
          end
        end
      }

    end
  end
end
