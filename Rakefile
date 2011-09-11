$:.unshift File.expand_path('../lib', __FILE__)
require 'rake'
require 'spec/rake/spectask'
require 'f2b'

task :default => [:spec]

desc "Generate a gemspec file"
task :build do
  system "gem build f2b.gemspec"
end

desc "Push gem to rubygems"
task :release => :build do 
  system "gem push f2b-#{F2b::VERSION}"
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = Dir.glob('spec/*_spec.rb')
end