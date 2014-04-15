lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'gplan'
  s.version     = '0.0.0'
  s.date        = '2014-04-14'
  s.authors     = ["Jeff Koenig"]
  s.email       = 'jkoenig311@gmail.com'
  s.homepage    = 'https://github.com/jkoenig311/gplan'
  s.summary     = "Creates release notes from the git log and planbox"
  s.description = "Creates release notes from the git log and planbox"
  s.executables      = ["gplan"]
  s.files        = Dir.glob("bin/**/*") + Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
