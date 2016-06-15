# require 'pivotaltracker'
# require 'jira-ruby'
require 'octokit'
require_relative './configure'
require_relative './branch_name'

class Track

  def initialize
    @tracker = CONFIG.tracker
    @project = getProject()
    @branch = getBranchName()
  end

  public
  def createIssue(title, body = nil, assignee = nil, milestone = nil, labels = nil)

    case @tracker
    when "github"
      @project.create_issue(CONFIG.repo, title, body, {:assignee => assignee, :milestone => milestone, :labels => labels})
    when "jira"
    when "pivotaltracker"
    else
      puts "Issue tracker not supported yet"
    end
  end

  def addComment(comment, issue_id = getCurrentIssue.number )
    @project.add_comment(CONFIG.repo, issue_id,  comment)
  end

  def addTask(task)
    #not for github
  end

  def getCurrentIssue
    findIssue(@branch)
  end

  def findIssue(branch)
    @project.issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
  end

  def commentAndClose(branch, comment)
    addComment(comment, findIssue(branch).number)
    resolveIssue(branch)
  end


  def resolveIssue(branch)
    @project.close_issue(CONFIG.repo, findIssue(branch).number, {:assignee => CONFIG.login} )
  end

  def listIssues(opts)
    options = {}
    options[:assignee] = CONFIG[@tracker].login if opts.mine
    options[:state] = "all" if opts.all
    options[:creator] = opts.creator if opts.creator != nil
    options[:mentioned] = opts.mentioned if opts.mentioned !=nil
    options[:milestone] = opts.milestone if opts.milestone !=nil # need to catch when milestone doesn't exist
    issues = @project.issues(CONFIG.repo, options)
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
    CONFIG.tracker = tracker
  end

  def signInWithCredentials(user, password)
    case @tracker
    when "github"
      CONFIG.login = user
      CONFIG.password = password
    end
  end


  def setRepo(repo)
    CONFIG.repo = repo
  end

  def getBranchName
    `git rev-parse --abbrev-ref HEAD`.gsub("\n", '')
  end

  def getRepo(repo)
    Octokit.repo repo
  rescue Octokit::InvalidRepository
  end


  def getProject
    case @tracker
    when "github"
      Octokit.configure do |c|
        c.login = CONFIG.login
        c.password = CONFIG.password
      end
      Octokit.client
    end
  end

  private


  def currentIssueID
    getIssue().number
  end

end
