# @see http://www.programmersparadox.com/2012/05/21/gemspec-loading-dependent-gems-based-on-the-users-system/
require 'rubygems/dependency_installer.rb'

installer = Gem::DependencyInstaller.new
begin
  unless RUBY_VERSION < '1.9'
    installer.install('unicode_utils', '>=0')
  end
rescue
  exit(1)
end

f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close
