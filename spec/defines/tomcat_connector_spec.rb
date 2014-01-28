require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::connector' do
    let (:title) {'ConnectBar'}
    let (:facts) { {
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbmajdistrelease         => v['lsbmajdistrelease'],
    } }

    context 'when using a wrong ensure value' do
      let (:params) {{
        :ensure   => 'foobar',
        :instance => 'instance1',
        :port     => '8422',
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /validate_re\(\):/)
      end
    end

    context 'when using a wrong port value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => 'aaa',
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /validate_re\(\):/)
      end
    end

    context 'when using a wrong instance value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => true,
        :port     => '8442',
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /.+ is not a string/)
      end
    end

    context 'when using a wrong owner value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :owner    => true
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /.+ is not a string/)
      end
    end

    context 'when using a wrong group value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :group    => true
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /.+ is not a string/)
      end
    end

    context 'when using a wrong connection_timeout value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :connection_timeout    => 'bbbb'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /validate_re\(\)/)
      end
    end

    context 'when using a wrong redirect_port value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :redirect_port    => 'bbbb'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /validate_re\(\)/)
      end
    end

    context 'when using a wrong options value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :options  => 'not_array'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /.+ is not an Array/)
      end
    end

    context 'when using a wrong manage value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :manage   => 'bibi'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /.+ is not a boolean/)
      end
    end

    context 'when using a wrong instance_basedir value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance1',
        :port     => '8442',
        :instance_basedir => 'some/relative/path'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__connector('ConnectBar')
        }.to raise_error(Puppet::Error, /.+ is not an absolute path/)
      end
    end

    let(:params) {{
      :instance         => 'instance1',
      :port             => '8442',
      :instance_basedir => '/srv/tomcat',
    }}

    describe 'should create /srv/tomcat/instance1/conf/connector-ConnectBar.xml' do
      it {
        should contain_file('/srv/tomcat/instance1/conf/connector-ConnectBar.xml').with({
          'ensure'  => 'present',
          'owner'   => 'tomcat',
          'group'   => 'adm',
          'mode'    => '0460',
          'replace' => false,
        })
        should contain_file('/srv/tomcat/instance1/conf/connector-ConnectBar.xml').with_content(/port="8442"/)
        should contain_file('/srv/tomcat/instance1/conf/connector-ConnectBar.xml').with_content(/protocol="HTTP\/1.1"/)
      }
    end


  end
}
