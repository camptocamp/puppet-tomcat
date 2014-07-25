require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../defines/parameters.rb'

@parameters.each { |k,v|
  describe "tomcat" do
    context k do
      let (:facts) { {
        :osfamily                  => v['osfamily'],
        :operatingsystem           => v['operatingsystem'],
        :operatingsystemmajrelease => v['operatingsystemmajrelease'],
        :lsbmajdistrelease         => v['lsbmajdistrelease'],
      } }

      describe 'should include basic classes' do
        it {
          should contain_class('tomcat::install')
          should contain_class('tomcat::user')
        }
      end

      describe 'should install tomcat package' do
        it {
          should contain_package(v['tomcat_package'])
        }
      end

      describe 'should include tomcat::logging and tomcat::juli' do
        it {
          should contain_class('tomcat::logging')
          should contain_class('tomcat::juli')
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
        '5' => '5.5.36',
        '6' => '6.0.41',
        '7' => '7.0.54',
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
}
