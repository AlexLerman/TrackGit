require 'git'
require 'logger'
require 'json'
require_relative "./track"
require_relative './branch_name'

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
    if @track.findIssue(story) != nil
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

  # def commit(message)
  #   @g.commit(message)
  #   commit = @g.gcommit(@g.revparse("HEAD"))
  # end

  def push(remote = 'origin', branch = @track.getBranchName(), opts = {})
    @g.push(remote, branch, opts)
    commits = getCommits()
    commits.each do |commit|
      @track.addComment(formatComment(commit, commit.message))
    end
  end

  # def merge(branch)
  #   @g.merge(branch)
  #   if @track.getBranchName == "master"
  #     comment = "Closed by merging to master"
  #     @track.commentAndClose(branch, comment)
  #   end
  # end

  def rebase(branch)

    if @track.getBranchName == "master"
      comment = "Closed by rebasing to master"
      @track.commentAndClose(branch, comment)
    end
    @g.rebase(branch)

  end


  def up
    @g.push("origin", @track.getBranchName)
  end

  def down
    @g.pull("origin", @track.getBranchName)
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

  def getCommits
    commits = []
    working_sha = getWorkingHead()
    @g.log.each do |log|
      if log.sha != working_sha
        commits.push(log)
      else
        break
      end
    end
    commits.reverse
  end



  def getWorkingHead
    working_branch = configatron.working_branch.to_s != "configatron.working_branch" ? configatron.working_branch : "master"
    `git fetch origin #{working_branch}`
    @g.revparse("#{working_branch}")
  end

  def convertToValidBranchName(name)
    BranchName.new(name).to_s
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

  #testing commit
  #test again

end
