require 'spec_helper_acceptance'

describe 'tomcat::instance' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'tomcat': }
        tomcat::instance { 'foo': }
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
