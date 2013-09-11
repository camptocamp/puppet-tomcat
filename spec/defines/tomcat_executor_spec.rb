require 'spec_helper'
require File.expand_path(File.direname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::executor' do
    let (:title) {'executorBar'}
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
    } }

    context 'when using a wrong ensure value' do
      let (:params) {{
        :ensure   => 'foobar',
        :instance => 'instance'
      }}
      it 'should fail' do
        expect { 
          should contain_tomcat__executor('executorBar')
        }.to raise_error(Puppet::ParseError, /validate_re\(\):/)
      end
    end
  end
}
