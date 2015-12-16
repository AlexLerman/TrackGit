require 'git'
require 'logger'
require 'tracker_api'
require 'trollop'




class TrackGit

  def initialize()
    @g = Git.open(".", :log => Logger.new(STDOUT))

  end

  public
  def createStory(story)
    story = convertToValidBranchName(story)
    @g.branch(story).checkout
  end

  def checkoutStory(story)
    @g.checkout(convertToValidBranchName(story))
  end

  def deleteBranch(branch)
    @g.branch(convertToValidBranchName(branch)).delete
  end

  def commit(message)
    @g.commit(message)
  end

  private
  def convertToValidBranchName(name)
    name.gsub(" ", '_')
  end



end



SUB_COMMANDS = %w(checkout createStory delete commit)
global_opts = Trollop::options do
  banner "magic file deleting and copying utility"
  opt :dry_run, "Don't actually do anything", :short => "-n"
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift # get the subcommand
cmd_opts = case cmd
when "checkout" # parse delete options
    Trollop::options do
      opt :test, "test"
    end
    TrackGit.new.checkoutStory(ARGV[0])
  when "createStory"  # parse copy options
    Trollop::options do
      opt :test, "test"
    end
    TrackGit.new.createStory(ARGV[0])
  when "delete"  # parse copy options
    TrackGit.new.deleteBranch(ARGV[0])
  when "commit"  # parse copy options
    TrackGit.new.commit(ARGV[0])
  else
    Trollop::die "unknown subcommand #{cmd.inspect}"
  end
