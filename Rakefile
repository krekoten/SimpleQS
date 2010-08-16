require 'rubygems'
require 'spec/rake/spectask'

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'rake/gempackagetask'

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--format', 'profile', '--color', '-b']
end

desc "Default task is to run specs"
task :default => :spec

spec = eval(File.read('simple_qs.gemspec'))                                                                                                               
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Release gem to gemcutter."
task :release do
  require 'rake/gemcutter'
  Rake::Gemcutter::Tasks.new(spec).define
  Rake::Task['gem:push'].invoke
end

