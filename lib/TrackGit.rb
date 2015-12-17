require 'git'
require 'logger'
require 'tracker_api'
require 'json'



class TrackGit

  def initialize
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
    else
      puts "There is no story by that name"
      # add option to create story if none exists
    end
  end

  def deleteBranch(branch)
    @g.branch(convertToValidBranchName(branch)).delete
  end

  def commit(message)
    story = getStory
    # write comment on story when commited.
    puts story.comments(fields: ':default,person')
    @g.commit(message)
  end

  def getComments
    story = getStory()
    puts story.comments(fields: ':default,person')
  end

  def addComment
    story = getStory()
    story.comments(text: "Hey, I just wrote a comment from the console")
  end

  private
  def convertToValidBranchName(name)
    name.gsub(" ", '_')
  end

  def convertToStoryName(name)
    name.gsub("_", ' ').gsub("\n", '')
  end

  def existingStory(story, stories)
    puts story
    puts stories
    stories.map! {|story| story.name}
    puts stories
    stories.include? story
  end

  def getStory
     story = @project.stories.detect {|story| convertToValidBranchName(story.name) == `git rev-parse --abbrev-ref HEAD`.gsub("\n", '') }
  end

end
