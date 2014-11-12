require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Ruby
  install_package host, 'ruby'
  # Install Puppet
  on host, "ruby --version | cut -f2 -d ' ' | cut -f1 -d 'p'" do |version|
    version = version.stdout.strip
    if Gem::Version.new(version) < Gem::Version.new('1.9')
      install_package host, 'rubygems'
    end
  end
  on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'tomcat')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','camptocamp-archive'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
