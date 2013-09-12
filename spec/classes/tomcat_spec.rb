require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k,v|
  describe "tomcat" do
    context k do
      let (:facts) { {
        :osfamily                  => v['osfamily'],
        :operatingsystem           => v['operatingsystem'],
        :operatingsystemmajrelease => v['operatingsystemmajrelease'],
        :lsbdistmajrelease         => v['lsbdistmajrelease'],
      } }

      describe 'should include basic classes' do
        it {
          should include_class('tomcat::install')
          should include_class('tomcat::user')
          should include_class('tomcat::service')
        }
      end

      describe 'should install tomcat package' do
        it {
          should contain_package(v['tomcat_package'])
        }
      end

      describe 'should include tomcat::logging and tomcat::juli' do
        it {
          should include_class('tomcat::logging')
          should include_class('tomcat::juli')
        }
      end

      describe "should install #{v['log4j']} and #{v['logging']}" do
        it {
          should contain_package(v['log4j'])
          should contain_package(v['logging'])
        }
      end

      describe 'should create tomcat user' do
        it {
          should contain_user('tomcat').with('system' => true)
        }
      end

      describe 'should deactivate default tomcat service' do
        it {
          should contain_service("tomcat#{v['tomcat_version']}").with({
            'ensure' => 'stopped',
            'enable' => false,
          })
          should contain_file("/etc/init.d/tomcat#{v['tomcat_version']}").with({
            'ensure' => 'file',
            'mode'   => '0644',
          })
        }
      end

      {
        '5.0.1' => 5,
        '6.0.1' => 6,
        '7.0.1' => 7,
      }.each { |version, maj|
        context "install tomcat#{version} from sources" do
          let(:params) {{
            :sources => true,
            :version => version,
          }}
          describe 'should include tomcat::source' do
            it {
              should include_class('tomcat::source')
            }
          end
          describe 'should download tomcat' do
            it {
              should contain_archive("apache-tomcat-#{version}").with({
                'url' => /tomcat-#{maj}\/v#{version}\/bin/,
              })
            }
          end
          describe 'should create tomcat home' do
            it {
              should contain_file("/opt/apache-tomcat-#{version}").with_ensure('directory')
            }
          end
          describe 'should create symlink' do
            it {
              should contain_file('/opt/apache-tomcat').with({
                'ensure'  => 'link',
                'target'  => "/opt/apache-tomcat-#{version}",
              })
            }
          end
        end
      }

    end
  end
}
