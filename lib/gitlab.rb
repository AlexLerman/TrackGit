# require 'pivotaltracker'
# require 'jira-ruby'
require 'gitlab'
require 'shellwords'
require_relative './commit'
require_relative './track'
require_relative './configure'
require_relative './branch_name'

class Github < Track

  def initialize
    @tracker = CONFIG.tracker
    @client = Gitlab.client(endpoint: CONFIG.endpoint, private_token: CONFIG.private_token)

  end

  public

  def commit()
    original_message = Commit.from_git_log_item(`git log -1`).message
    issue_number_tag = "\n##{getCurrentBranchName.split('_')[0]}"
    `git commit --amend -m #{Shellwords.escape original_message + issue_number_tag}`
  end

  def createIssue(title, body = nil, assignee = nil, milestone = nil, labels = nil)
    @client.create_issue(CONFIG.repo, title, {:description => body, :assignee_id => assignee, :milestone_id => milestone, :labels => labels})
  end

  def addComment(comment, issue_id = getCurrentIssue.number )
    @client.create_issue_note(CONFIG.repo, issue_id,  comment)
  end

  def addTask(task)
    puts "gitlab does not support tasks"
  end

  def findIssue(branch)
    @client.issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
  end

  def resolveIssue(branch)
    @client.edit_issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number, :assignee_id => CONFIG.login)
    @client.close_issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
  end

  def listIssues(opts)
    issues = @client.issues(CONFIG.repo)
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


  def signInWithCredentials(user, private_token, endpoint)
    CONFIG.login = user
    CONFIG.private_token = private_token
    CONFIG.endpoint = endpoint
  end

  def setRepo(repo)
    CONFIG.reponame = repo
    CONFIG.repo = @client.project(repo).id

  end

  def getRepo(repo)
    Octokit.repo repo
  rescue Octokit::InvalidRepository
  end




end
