require 'git'
require 'logger'


g = Git.open(".", :log => Logger.new(STDOUT))

g.add(['./TrackGit.rb', './Gemfile' ])
g.commit('Commiting TrackGit.rb and Gemfile')
