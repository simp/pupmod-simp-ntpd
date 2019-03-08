require 'simp/rake/pupmod/helpers'
require 'puppet-strings/tasks'

unless ENV['FIXTURES_YML']
  if Gem::Version.new(Puppet.version) >= Gem::Version.new('6')
    ENV['FIXTURES_YML'] = File.join(File.dirname(__FILE__), '.fixtures6.yml')
  end
end

Simp::Rake::Pupmod::Helpers.new(File.dirname(__FILE__))
