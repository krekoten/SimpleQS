require 'rubygems'
require 'spec/rake/spectask'

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--format', 'profile', '--color', '-b']
end

desc "Default task is to run specs"
task :default => :spec
