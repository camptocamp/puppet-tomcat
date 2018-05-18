require 'spec_helper_acceptance'

describe 'tomcat' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'tomcat': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'with source' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'tomcat':
          sources    => true,
          srcversion => '6.0.41',
          version    => '6',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
