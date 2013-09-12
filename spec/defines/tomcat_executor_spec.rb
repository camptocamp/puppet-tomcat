require 'spec_helper'
require File.expand_path(File.dirname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::executor' do
    let (:title) {'executorBar'}
    let (:facts) { {
      :osfamily                  => v['osfamily'],
      :operatingsystem           => v['operatingsystem'],
      :operatingsystemmajrelease => v['operatingsystemmajrelease'],
      :lsbdistmajrelease         => v['lsbdistmajrelease'],
    } }

    context 'when using a wrong ensure value' do
      let (:params) {{
        :ensure   => 'foobar',
        :instance => 'instance'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /validate_re\(\):/)
      end
    end

    context 'when using a wrong owner value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :owner    => true
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /.+ is not a string/)
      end
    end

    context 'when using a wrong group value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :group    => true
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /.+ is not a string/)
      end
    end

    context 'when using a wrong daemon value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :daemon   => 'foobar'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /.+ is not a boolean/)
      end
    end

    context 'when using a wrong max_threads value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :max_threads => 'string'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /validate_re\(\)/)
      end
    end

    context 'when using a wrong min_spare_threads value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :min_spare_threads => 'string'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /validate_re\(\)/)
      end
    end

    context 'when using a wrong max_idle_time value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :max_idle_time => 'string'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /validate_re\(\)/)
      end
    end

    context 'when using a wrong manage value' do
      let (:params) {{
        :ensure   => 'present',
        :instance => 'instance',
        :manage   => 'bbbb'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::Error, /.+ is not a boolean/)
      end
    end

    let(:params) {{
      :instance => 'instance1',
    }}
    describe 'should create a file' do
      it {
        should contain_file('/srv/tomcat/instance1/conf/executor-executorBar.xml').with({
          'ensure'  => 'present',
          'owner'   => 'tomcat',
          'group'   => 'adm',
          'mode'    => '0460',
          'replace' => false,
        })
        should contain_file('/srv/tomcat/instance1/conf/executor-executorBar.xml').with_content(/name="executorBar"/)
      }
    end

  end
}
