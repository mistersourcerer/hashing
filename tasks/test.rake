desc "run all tests"

args = ARGV
args.shift
files = args

desc "run all the tests"

task :test do
  lib = File.expand_path("../lib", __FILE__)
  $: << lib

  loader = ->(files_list){
    files_list.each do |f|
      if File.directory?(f)
        loader.call(Dir.glob(f + "/**/*_test.rb"))
      else
        load f
      end
    end
  }

  require_relative "../test/test_helper"
  files = Dir.glob("test/**/*_test.rb") unless files.size > 0
  loader.call(files)
end
