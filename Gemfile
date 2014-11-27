source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false, :git => 'https://github.com/camptocamp/rspec-puppet.git', :branch => 'future-no-import'
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
  gem 'metadata-json-lint',      :require => false
  gem 'puppet_facts',            :require => false, :git => 'https://github.com/camptocamp/puppet_facts.git'
  gem 'serverspec',              :require => false
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
  gem 'pry',                     :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
