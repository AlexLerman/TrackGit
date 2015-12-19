require 'git'
require 'logger'
require 'tracker_api'
require 'json'
require_relative "./track"


class TrackGit
  @track = Track.new

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

  def createIssue(story)
    @track.createIssue(story)
    story = convertToValidBranchName(story)
    @g.branch(story).checkout
  end

  def checkoutStory(story)
    if @track.getIssue(story) != nil
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
    @g.commit(message)
    commit = @g.gcommit(@g.revparse("HEAD"))
    addComment(formatComment(commit, message))
  end

  def push(remote = 'origin', branch = getBranchName(), opts = {})
    @g.push(remote, branch, opts)
  end

  def add(files)
    @g.add(files) # "filename" or ["file1", "file2"]
  end

  def getComments
    @track.getComments
  end

  def addComment(comment)
    @track.addComment(comment)
  end

  def remove(files)
    @g.remove(files)
  end

  private
  def convertToValidBranchName(name)
    name.gsub(" ", '_')
  end

  def convertToStoryName(name)
    name.gsub("_", ' ').gsub("\n", '')
  end

  def existingStory(story, stories)
    stories.map! {|story| story.name}
    stories.include? story
  end

  def getStory
     story = @project.stories.detect {|story| convertToValidBranchName(story.name) == `git rev-parse --abbrev-ref HEAD`.gsub("\n", '') }
  end

  def formatComment(commit, message)
    "#{message} \n Commit #{commit.sha} by #{commit.author.name}"
  end

end
