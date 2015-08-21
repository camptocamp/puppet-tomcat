require 'beaker-rspec'

hosts.each do |host|
  # Install Puppet
  install_puppet()
  # Install ruby-augeas
  case fact('osfamily')
  when 'Debian'
    install_package host, 'libaugeas-ruby'
  when 'RedHat'
    install_package host, 'net-tools'
    install_package host, 'make'
    install_package host, 'gcc'
    install_package host, 'ruby-devel'
    install_package host, 'augeas-devel'
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
    on host, 'yum makecache'
  else
    puts 'Sorry, this osfamily is not supported.'
    exit
  end
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
      on host, puppet('module','install','camptocamp-archive'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','camptocamp-systemd'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','herculesteam-augeasproviders_core'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','herculesteam-augeasproviders_shellvar'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
