require "bundler/gem_tasks"

Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |rake| load rake }
task default: "test"

desc 'line number statistics'
task :lines do
  libdir = File.join File.dirname(__FILE__), 'lib'
  Dir["lib/**/*.rb"].each { |file|
    lines = File.readlines(file).reject { |line| line =~ /^(\s*)#/ }.count
    puts "#{lines.to_s.rjust(3)} in #{file}"
  }
end
