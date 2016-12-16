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
    @branch = getCurrentBranchName()
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

  def addComment(comment, issue_id = currentIssueID)
    @project.add_comment(CONFIG.repo, issue_id,  comment)
  end

  def getComments(issue_id = currentIssueID)
    arr = @project.issue_comments(CONFIG.repo, issue_id, options = {})
    arr.each do |c|
      puts c.user.login + " says:"
      puts "   " + c.body + "\n\n"
    end
  end

  def addTask(task)
    puts "github does not support tasks"
  end

  def findIssue(branch)
    @project.issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
  end

  def findIssueByID(issue_id)
    @project.issue(CONFIG.repo, issue_id)
  end

  def resolveIssue(branch)
    @project.close_issue(CONFIG.repo, findIssue(branch).number, {:assignee => CONFIG.login} )
  end

  def resolveIssueNumber(issue_number)
    @project.close_issue(CONFIG.repo, issue_number, {:assignee => CONFIG.login} )
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
    CONFIG.auth_token = token
  end


  def signInWithCredentials(user, password)
    CONFIG.login = user
    CONFIG.password = password
    #client = Octokit::Client.new(:login => user, :password => password)
    #CONFIG.auth_token = client.create_authorization(:scopes => ["user", "repo"], :note => "TrackGit Auth Token")

  end

  def signInWith2FA(user, password, tfa_key, repo)
    CONFIG.login = user
    CONFIG.password = password
    client = Octokit::Client.new(:login => user, :password => password)
    note = "TrackGit Auth Token for " + `git rev-parse --show-toplevel`.chomp
    puts "Creating " + note
    auth_token = client.create_authorization(:scopes => ["user", "repo"], :note => note, :headers => { "X-GitHub-OTP" => tfa_key.to_s })
    CONFIG.auth_token = auth_token.to_h[:token]
  end

  def getRepo(repo)
    Octokit.configure do |c|
    end
    Octokit.repo repo
  rescue Octokit::InvalidRepository
  end

  def getProject
    if CONFIG.auth_token
      Octokit.configure do |c|
        c.access_token = CONFIG.auth_token
      end
    else
      Octokit.configure do |c|
        c.login = CONFIG.login
        c.password = CONFIG.password
      end
    end
    Octokit.client

  end



end
