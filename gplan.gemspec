lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'gplan'
  s.version       = '0.1.4'
  s.date          = '2015-04-06'
  s.authors       = ["Jeff Koenig"]
  s.email         = 'jkoenig311@gmail.com'
  s.homepage      = 'https://github.com/el-jefe-/gplan'
  s.summary       = "Creates release notes from the git log and planbox"
  s.description   = "Creates release notes from the git log and planbox"
  s.executables   = ["gplan"]
  s.files         = `git ls-files`.split($\)
  s.require_paths = ['lib']
  s.add_runtime_dependency('httparty', "~> 0.13")
  s.add_runtime_dependency('haml', "~> 4.0.5")
  s.add_runtime_dependency('rake',"~> 10.4.2")
end
