require 'git'
require 'logger'
require 'tracker_api'
require 'json'
require_relative "./track"


class TrackGit

  def initialize
    @g = Git.open(".")
    @track = Track.new

  end

  public

  def login(credentials)
    @track.signInWithCredentials(*credentials)
  end

  def setTracker(tracker)
    @track.setTracker(tracker)
  end

  def setRepo(repo)
    @track.setRepo(repo)
  end

  def createIssue(details)
    @track.createIssue(*details)
    story = convertToValidBranchName(details[0])
    @g.branch(story).checkout
  end

  def checkoutIssue(story)
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

  def getRepo
    @g.config["remote.origin.url"].gsub(".git", "").gsub("git@github.com:", "")
  end

end
