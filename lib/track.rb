# require 'pivotaltracker'
# require 'jira-ruby'
require 'octokit'
require_relative './config'

class Track

  def initialize
    @tracker = configatron.tracker()
    @project = getProject()
    @branch = getBranchName()
  end

  public
  def createIssue(title, body = nil, assignee = nil, milestone = nil, labels = nil)

    case @tracker
    when "github"
      @project.create_issue(configatron.repo, title, body, {:assignee => assignee, :milestone => milestone, :labels => labels})
    when "jira"
    when "pivotaltracker"
    else
      puts "Issue tracker not supported yet"
    end
  end

  def addComment(comment, issue_id = getCurrentIssue.number )
    @project.add_comment(configatron.repo, issue_id,  comment)
  end

  def addTask(task)
    #not for github
  end

  def getCurrentIssue
    issues = @project.issues(configatron.repo)
    issues.detect {|i| convertToValidBranchName(i.title) == @branch}
  end

  def findIssue(issue)
    issues = @project.issues(configatron.repo)
    issues.detect {|i| convertToValidBranchName(i.title) == convertToValidBranchName(issue)}
  end

  def commentAndClose(branch, comment)
    addComment(comment, findIssue(branch).number)
    resolveIssue(branch)
  end


  def resolveIssue(issue)
    @project.close_issue(configatron.repo, findIssue(issue).number, {:assignee => configatron[@tracker].login} )
  end

  def listIssues(opts)
    options = {}
    options[:assignee] = configatron.github.login if opts.mine
    options[:state] = "all" if opts.all
    options[:creator] = opts.creator if opts.creator != nil
    options[:mentioned] = opts.mentioned if opts.mentioned !=nil
    options[:milestone] = opts.milestone if opts.milestone !=nil # need to catch when milestone doesn't exist
    issues = @project.issues(configatron.repo, options)
    issues.each do |i|
      puts "#{i.number} #{i.title}"
    end
  end

  def listAssignedIssues
  end

  def listComments
  end

  def addLabel
  end

  def listLabels
  end

  def updateDescription
  end

  def deleteIssue
  end

  def listMilestones
  end

  def signInWithToken(token)
  end

  def setTracker(tracker = "github")
    configatron.tracker = tracker
    File.write(File.join( __dir__, 'config.yml'), configatron.to_h.to_yaml)
  end

  def signInWithCredentials(user, password)
    case @tracker
    when "github"
      configatron[@tracker].login = user
      configatron[@tracker].password = password
      File.write(File.join( __dir__, 'config.yml'), configatron.to_h.to_yaml)
    end
  end


  def setRepo(repo)
    configatron.repo = repo
    File.write(File.join( __dir__, 'config.yml'), configatron.to_h.to_yaml)
  end

  def getBranchName
    `git rev-parse --abbrev-ref HEAD`.gsub("\n", '')
  end

  private


  def convertToValidBranchName(name)
    name.gsub(" ", '_')
  end

  def getProject
    case @tracker
    when "github"
      Octokit.configure do |c|
        c.login = configatron[@tracker].login
        c.password = configatron[@tracker].password
      end
      Octokit.client
    end
  end

  def currentIssueID
    getIssue().number
  end

end
