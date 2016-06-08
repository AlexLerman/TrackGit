Gem::Specification.new do |s|
  s.name        = 'trackgit'
  s.version     = '0.0.0'
  s.executables << 'tg'
  s.date        = '2015-12-16'
  s.summary     = "Interface for automatic project tracking for git"
  s.description = "What he said"
  s.authors     = ["Alex Lerman", "Ben Christel"]
  s.files       = Dir['{bin,lib,test}/**/*', 'README*'] & `git ls-files -z`.split("\0")

  s.homepage    =
    'http://github.com/AlexLerman/TrackGit'
  s.license       = 'MIT'
end
