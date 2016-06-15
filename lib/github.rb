# require 'pivotaltracker'
# require 'jira-ruby'
require 'octokit'
require 'shellwords'
require_relative './commit'
require_relative './track'
require_relative './configure'
require_relative './branch_name'

class Github < Track

  def initialize
    @tracker = CONFIG.tracker
    @project = getProject()
  end

  public

  def commit()
    original_message = Commit.from_git_log_item(`git log -1`).message
    issue_number_tag = "\n##{getCurrentBranchName.split('_')[0]}"
    `git commit --amend -m #{Shellwords.escape original_message + issue_number_tag}`
  end

  def createIssue(title, body = nil, assignee = nil, milestone = nil, labels = nil)
    @project.create_issue(CONFIG.repo, title, body, {:assignee => assignee, :milestone => milestone, :labels => labels})
  end

  def addComment(comment, issue_id = getCurrentIssue.number )
    @project.add_comment(CONFIG.repo, issue_id,  comment)
  end

  def addTask(task)
    puts "github does not support tasks"
  end

  def findIssue(branch)
    @project.issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
  end

  def resolveIssue(branch)
    @project.close_issue(CONFIG.repo, findIssue(branch).number, {:assignee => CONFIG.login} )
  end

  def listIssues(opts)
    options = {}
    options[:assignee] = CONFIG.login if opts.mine
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


  def signInWithCredentials(user, password)
    CONFIG.login = user
    CONFIG.password = password
  end


  def getRepo(repo)
    Octokit.repo repo
  rescue Octokit::InvalidRepository
  end


  def getProject
    Octokit.configure do |c|
      c.login = CONFIG.login
      c.password = CONFIG.password
    end
    Octokit.client

  end



end
