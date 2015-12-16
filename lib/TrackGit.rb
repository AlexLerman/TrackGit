require 'git'
require 'logger'
require 'tracker_api'
require 'trollop'
require 'json'





class TrackGit

  def initialize()
    @g = Git.open(".", :log => Logger.new(STDOUT))
    if File.exist?("credentials")
      apiToken = JSON.parse(File.read("credentials"))["token"]
      client = TrackerApi::Client.new(token: apiToken)
      puts client.projects.inspect
      @project = client.project(1500636)
                  # Create API client
    else
      client = nil
    end
  end

  public

  def saveClientInfo(apiToken)
    tokenHash = {:token => apiToken}
    File.write("credentials", JSON.generate(tokenHash))
  end

  def createStory(story)
    @project.create_story(name: story)
    story = convertToValidBranchName(story)
    @g.branch(story).checkout
  end

  def checkoutStory(story)
    if existingStory(story, @project.stories)
      story = convertToValidBranchName(story)
      @g.branch(story).checkout
    end
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

  def existingStory(story, stories)
    puts story
    puts stories
    stories.map! {|story| story.name}
    puts stories
    stories.include? story
  end



end

track = TrackGit.new

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
    track.checkoutStory(ARGV[0])
  when "createStory"  # parse copy options
    Trollop::options do
      opt :test, "test"
    end
    track.createStory(ARGV[0])
  when "delete"  # parse copy options
    track.deleteBranch(ARGV[0])
  when "commit"  # parse copy options
    track.new.commit(ARGV[0])
  when "saveClientInfo"
    track.saveClientInfo(ARGV[0])
  else
    Trollop::die "unknown subcommand #{cmd.inspect}"
  end
