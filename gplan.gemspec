lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'gplan'
  s.version       = '0.2.0'
  s.date          = '2016-06-02'
  s.authors       = ["Jeff Koenig"]
  s.email         = 'jkoenig311@gmail.com'
  s.homepage      = 'https://github.com/thejefe/gplan'
  s.summary       = "Creates release notes from the git log and planbox"
  s.description   = "Creates release notes from the git log and planbox"
  s.executables   = ["gplan"]
  s.files        = Dir.glob("bin/**/*") + Dir.glob("lib/**/*") + Dir.glob("templates/**/*") + %w(README.md)
  s.require_paths = ['lib']
  s.add_runtime_dependency('httparty', "~> 0.13")
  s.add_runtime_dependency('haml', "~> 4.0")
end
