# encoding: utf-8
$:.unshift File.expand_path('../lib', __FILE__)
require 'f2b'

Gem::Specification.new do |s|
  s.name = 'f2b'
  s.version = F2b::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Rainer Borene"]
  s.email = "me@rainerborene.com"
  s.homepage = "https://github.com/rainerborene/f2b"
  s.summary = "F2b - Serviço de Cobranças"
  s.description = "Integração com o serviço da F2b para envio e agendamento de cobranças."
  s.required_ruby_version = ">= 1.8.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_path = 'lib'
  
  s.add_dependency("curb", ">= 0.7.8")
  s.add_dependency("nokogiri", ">= 0")
  s.add_dependency("handsoap", ">= 1.1.7")
end
