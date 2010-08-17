require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'version'))

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'simple_qs'
  s.version     = SimpleQS::VERSION
  s.summary     = 'Amazon SQS service library'
  s.description = 'SimpleQS library fully wraps Amazon SQS REST API. It allows you perform all kind of calls on queues and messages.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.author            = "Marjan Krekoten' (Мар'ян Крекотень)"
  s.email             = 'krekoten@gmail.com'
  s.homepage          = 'http://github.com/krekoten/SimpleQS'

  s.add_dependency('xml-simple', '>= 1.0.12')
  s.add_dependency('ruby-hmac', '>= 0.3.2')
  
  s.add_development_dependency("rspec")
  
  s.require_path = 'lib'
  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG.md TODO.md)
end
