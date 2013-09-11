require 'spec_helper'
require File.expand_path(File.direname(__FILE__)) + '/parameters.rb'

@parameters.each { |k, v|
  describe 'tomcat::connector' do
    let (:title) {'ConnectBar'}
    let (:facts) { {
      :osfamily        => v['osfamily'],
      :operatingsystem => k
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
        }.to raise_error(Puppet::ParseError, /validate_re\(\):/)
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
        }.to raise_error(Puppet::ParseError, /validate_re\(\):/)
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
        }.to raise_error(Puppet::ParseError, /.+ is not a string/)
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
        }.to raise_error(Puppet::ParseError, /.+ is not a string/)
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
        }.to raise_error(Puppet::ParseError, /.+ is not a string/)
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
        }.to raise_error(Puppet::ParseError, /validate_re\(\)/)
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
        }.to raise_error(Puppet::ParseError, /validate_re\(\)/)
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
        }.to raise_error(Puppet::ParseError, /.+ is not an Array/)
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
        }.to raise_error(Puppet::ParseError, /.+ is not a boolean/)
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
        }.to raise_error(Puppet::ParseError, /.+ is not an absolute path/)
      end
    end


  end
}
