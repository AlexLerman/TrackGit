require 'git'
require 'logger'
require 'json'
require 'shellwords'
require_relative "./github"
require_relative './branch_name'
require_relative './commit'
require 'io/console'


class TrackGit

  def initialize
    @g = Git.open(".")
    @track = setTracker(CONFIG.tracker)
    @supported = [ "github"]
  end

  public

  def login(credentials)
    @track.signInWithCredentials(*credentials)
  end

  def setTracker(tracker)
    CONFIG.tracker = tracker
    case tracker
    when "github"
      Github.new
    # when "gitlab"
    #   Gitlab.new
    end
  end

  def setup()
    tracker = prompt("What tracker are you using? ")
    until @supported.include?(tracker)
      puts "Tracker not supported, sorry. "
      tracker = prompt("What tracker are you using? ")
    end
    @track = setTracker(tracker)
    repo = nil
    username = prompt("What's your username? ")
    password = promptPassword("What's your password? ")
    login([username, password])
    while !validRepo(repo)
      repo = prompt("What is your repository? ")
    end
    setRepo(repo)
    prod = prompt("Create production branch? [Y/n] ")
    if prod == "" or prod[0].downcase == "y"
      @g.branch("prod").create
    end

  end

  def prompt(prompt)
    print prompt
    gets.chomp
  end

  def promptPassword(prompt)
    print prompt
    password = STDIN.noecho(&:gets).chomp
    puts
    password
  end

  def validRepo(repo)
    if repo != nil
      if @track.getRepo(repo) == nil
        puts "Invalid repository. Use user/repo"
        return false
      end
      return true
    end
  end

  def setRepo(repo)
    @track.setRepo(repo)
  end

  def createIssue(details)
    issue = @track.createIssue(*details)
    story = BranchName.new(issue.title, issue.number).to_branch_name
    @g.branch(story).checkout
  end

  def checkoutIssue(story_or_branch_name)
    if story_or_branch_name == "master" || story_or_branch_name == "prod"
      @g.branch(story_or_branch_name).checkout
      return
    end

    puts "checkoutIssue"
    if branch = findBranch(story_or_branch_name)
      puts "inside if; branch = #{branch.inspect}"
      branch.checkout
      return
    end
    puts "got here...."
    story = story_or_branch_name

    issue = @track.findIssue(story)
    if  issue != nil
      puts "found the issue"
      story = BranchName.new(issue.title, issue.number).to_branch_name
      @g.branch(story).checkout
    else
      puts "There iss no story by zat name"
      # add option to create story if none exists
    end
  end

  def deleteBranch(branch)
    findBranch(branch).delete
  end

  def findBranch(name)
    branches = @g.branches
    branches.detect do |branch|
      BranchName.new(name, 0).to_s == remove_number(branch.name)
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
    @track.commit()
  end


  def push(remote = 'origin', branch = @track.getCurrentBranchName(), opts = {})
    @g.push(remote, branch, opts)
  end

  def getIssueId(message)
  end

  def merge(branch)
    if @track.getCurrentBranchName == "master"
      comment = "Closed by merging to master"
      @track.commentAndClose(branch, comment)
    end
    `git merge #{branch}`
  end

  def rebase(branch)

    if @track.getCurrentBranchName == "master"
      comment = "Closed by rebasing to master"
      @track.commentAndClose(branch, comment)
    end
    `git rebase #{branch}`
  end

  def finish
    if (system 'git diff --exit-code') #checks for uncommited changes
      up()
      branch = getCurrentBranchName
      checkoutIssue("master")
      merge(branch)
      up()
    else
      puts "\n\nUncommited changes. Stash or commit!"
    end
  end

  def changesStaged

  end

  def listIssues(opts)
    @track.listIssues(opts)
  end

  def up
    @g.push("origin", @track.getCurrentBranchName)
  end

  def down
    @g.pull("origin", @track.getCurrentBranchName)
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
