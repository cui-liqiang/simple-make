Gem::Specification.new do |s|
  s.name        = 'simple-make'
  s.version     = '0.0.1'
  s.date        = '2013-12-30'
  s.summary     = "convention over configuration c/c++ file build tool"
  s.description = "A tool to help you create makefile base on a build.sm file."
  s.authors     = ["Cui Liqiang"]
  s.email       = 'cui.liqiang@gmail.com'
  s.files       = (`find .`.split "\n").reject{|name| %w(sample README gemspec spec git rvmrc).any?{|ex|name.include? ex}}
  s.homepage    = ""
  s.executables << 'sm'
  s.license       = 'MIT'
end