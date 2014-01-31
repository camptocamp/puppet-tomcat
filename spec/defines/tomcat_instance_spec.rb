require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::instance' do
    let(:pre_condition) { 'include tomcat' }
    let (:title) {'fooBar'}
    let (:facts) { {
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
    } }

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
      if k.include? 'RHEL5'
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
          should contain_file("/srv/tomcat/fooBar/conf/server.xml").with({
            'ensure'  => 'file',
            'owner'   => 'tomcat',
            'group'   => 'adm',
            'mode'    => '0460',
            'source'  => /server.xml_fooBar/,
          })
        }

      end
    end

    describe "should create bin/setenv.sh" do
      it {
        should contain_file("/srv/tomcat/fooBar/bin/setenv.sh").with({
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'adm',
          'mode'    => '0754',
        })
      }
    end

    describe "should create bin/setenv-local.sh" do
      it {
        should contain_file("/srv/tomcat/fooBar/bin/setenv-local.sh").with({
          'ensure'  => 'file',
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
        should contain_file('/etc/init.d/tomcat-fooBar').with({
          'ensure' => 'file',
          'owner'  => 'root',
          'mode'   => '0755',
        })
        should contain_file('/etc/init.d/tomcat-fooBar').with_content(/JAVA_HOME=#{v['java_home']}/)
      }
    end

    context 'add some env variables' do
      let(:params) {{
        :setenv => ['JAVA_XMX="512m"', 'JAVA_XX_MAXPERMSIZE="512m"']
      }}
      it {
        should contain_file('/srv/tomcat/fooBar/bin/setenv.sh').with({
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'adm',
          'mode'    => '0754',
        })
        should contain_file('/srv/tomcat/fooBar/bin/setenv.sh').with_content(/JAVA_XMX=\"512m\"/)
        should contain_file('/srv/tomcat/fooBar/bin/setenv.sh').with_content(/JAVA_XX_MAXPERMSIZE=\"512m\"/)
      }
    end

    context 'enable sample' do
      let(:params) {{
        :sample => true
      }}
      it {
        should contain_file("/srv/tomcat/fooBar/webapps/sample.war").with({
          'ensure' => 'present',
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
}
