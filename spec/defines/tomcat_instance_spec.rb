require 'spec_helper'
require File.expand_path(File.direname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::instance' do
    let (:title) {'fooBar'}
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
    } }

    context 'when using a wrong ensure value' do
      let (:params) {{
        :ensure => 'foobar',
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /validate_re\(\):/)
      end
    end

    context 'when using a wrong owner value' do
      let(:params) {{
        :owner => true
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /.+ is not a string/)
      end
    end

    context 'when using a wrong group value' do
      let(:params) {{
        :group => true
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /.+ is not a string/)
      end
    end

    context 'when using a wrong server_port value' do
      let(:params) {{
        :server_port => 'aaaa'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /validate_re\(\)/)
      end
    end

    context 'when using a wrong http_port value' do
      let(:params) {{
        :http_port => 'bbbb'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /validate_re\(\)/)
      end
    end

    context 'when using a wrong ajp_port value' do
      let(:params) {{
        :ajp_port => 'bbbb'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /validate_re\(\)/)
      end
    end

    context 'when using a wrong setenv value' do
      let(:params) {{
        :setenv => 'not_array'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /.* is not an Array/)
      end
    end

    context 'when using a wrong connector value' do
      let(:params) {{
        :connector => 'not_array'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /.+ is not an Array/)
      end
    end

    context 'when using a wrong executor value' do
      let(:params) {{
        :executor => 'not_array'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /.+ is not an Array/)
      end
    end

    context 'when using a wrong instance_basedir value' do
      let(:params) {{
        :instance_basedir => 'some/relative/path'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /.+ is not an absolute path/)
      end
    end

    context 'when using a wrong version value' do
      let(:params) {{
        :version => 'bbbb'
      }}
      it 'should fail' do
        expect {
          should contain_tomcat__instance('fooBar')
        }.to raise_error(Puppet::ParseError, /validate_re\(\)/)
      end
    end

  end
}
