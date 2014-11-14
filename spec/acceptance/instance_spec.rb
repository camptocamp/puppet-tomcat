require 'spec_helper_acceptance'

describe 'tomcat::instance' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'tomcat': }
        tomcat::instance { 'foo':
          manage => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8005) do
      it { is_expected.to be_listening }
    end

    describe port(8009) do
      it { is_expected.to be_listening }
    end

    describe port(8080) do
      it { is_expected.to be_listening }
    end
  end

  context 'with another http port' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'tomcat': }
        tomcat::instance { 'foo':
          http_port => '8081',
          manage    => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8005) do
      it { is_expected.to be_listening }
    end

    describe port(8009) do
      it { is_expected.to be_listening }
    end

    describe port(8080) do
      it { should_not be_listening }
    end

    describe port(8081) do
      it { is_expected.to be_listening }
    end
  end

  context 'with an env variable set' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'tomcat': }
        tomcat::instance { 'foo':
          manage => true,
          setenv => ['USE_IMAGEMAGICK="true"',],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(8005) do
      it { is_expected.to be_listening }
    end

    describe port(8009) do
      it { is_expected.to be_listening }
    end

    describe port(8080) do
      it { is_expected.to be_listening }
    end
  end

end
