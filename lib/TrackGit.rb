require 'git'
require 'logger'
require 'json'
require 'shellwords'
require_relative "./track"
require_relative './branch_name'
require_relative './commit'

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
    issue = @track.createIssue(*details)
    story = BranchName.new(issue.title, issue.number).to_branch_name
    @g.branch(story).checkout
  end

  def checkoutIssue(story)
    issue = @track.findIssue(story)
    if  issue != nil
      story = BranchName.new(issue.title, issue.number).to_branch_name
      @g.branch(story).checkout
    else
      puts "There iss no story by zat name"
      # add option to create story if none exists
    end
  end

  def deleteBranch(branch)
    @g.branch(findBranch(branch)).delete
  end

  def findBranch(name)
    branches = @g.branches.map{ |branch| branch.name }
    branches.detect do |branch|
      BranchName.new(name, 0).to_s == remove_number(branch)
    end
  end

  def remove_number(branch)
    branch.split('_', 2)[1]
  end

  # def commit(message)
  #   @g.commit(message)
  #   commit = @g.gcommit(@g.revparse("HEAD"))
  # end


  def commit(all_arguments)
    system("git#{all_arguments}")
    original_message = Commit.from_git_log_item(`git log -1`).message
    issue_number_tag = "\n##{getCurrentBranchName.split('_')[0]}"
    `git commit --amend -m #{Shellwords.escape original_message + issue_number_tag}`
  end

  def push(remote = 'origin', branch = @track.getBranchName(), opts = {})
    @g.push(remote, branch, opts)
    commits = getCommits()
    commits.each do |commit|
      issueId = Commit.new(commit.message).getIssueId
      puts issueId
      @track.addComment(formatComment(commit, commit.message), issueId)
    end
  end

  def getIssueId(message)
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
    `git rebase #{branch}`
  end

  def listIssues(opts)
    @track.listIssues(opts)
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

  def convertToStoryName(name)
    name.gsub("_", ' ').gsub("\n", '')
  end

  def existingStory(story, stories)
    stories.map! {|story| story.name}
    stories.include? story
  end

  def getCurrentBranchName
    `git rev-parse --abbrev-ref HEAD`
  end

  # def getStory
  #    story = @project.stories.detect {|story| convertToValidBranchName(story.name) == `git rev-parse --abbrev-ref HEAD`.gsub("\n", '') }
  # end

  def formatComment(commit, message)
    "#{message} \n Commit #{commit.sha} by #{commit.author.name}"
  end

  def getRepo
    @g.config["remote.origin.url"].gsub(".git", "").gsub("git@github.com:", "")
  end

  #testing commit
  #test again

end
