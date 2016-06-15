# require 'pivotaltracker'
# require 'jira-ruby'
require 'gitlab'
require 'shellwords'
require_relative './commit'
require_relative './track'
require_relative './configure'
require_relative './branch_name'

class GitlabTracker < Track

  def initialize
    @tracker = CONFIG.tracker
    @client = Gitlab.client(endpoint: CONFIG.endpoint, private_token: CONFIG.private_token)

  end

  public

  def commit()
    original_message = Commit.from_git_log_item(`git log -1`).message
    addComment(original_message)
  end

  def genericIssue(issue)
    Struct.new("GenIssue", :title, :number)
    Struct::GenIssue.new(issue.title, issue.id)
  end

  def createIssue(title, body = nil, assignee = nil, milestone = nil, labels = nil)
    issue = @client.create_issue(CONFIG.repo, title, {:description => body, :assignee_id => assignee, :milestone_id => milestone, :labels => labels})
    genericIssue(issue)
  end



  def addComment(comment, issue_id = getCurrentIssue.number )
    @client.create_issue_note(CONFIG.repo, issue_id,  comment)
  end

  def addTask(task)
    puts "gitlab does not support tasks"
  end

  def findIssue(branch)
    issue = @client.issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
    genericIssue(issue)
  end

  def resolveIssue(branch)
    @client.edit_issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number, :assignee_id => CONFIG.user_id)
    @client.close_issue(CONFIG.repo, BranchName.new(branch, 0).get_issue_number)
  end

  def listIssues(opts)
    issues = @client.issues(CONFIG.repo)
    issues.each do |i|
      puts "#{i.id} #{i.title}"
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
    CONFIG.private_token = token
  end

  def setUser(user)
    CONFIG.login = user
    @client = Gitlab.client(endpoint: CONFIG.endpoint, private_token: CONFIG.private_token)
    CONFIG.user_id = @client.user.id
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
    @client.project repo
  rescue Gitlab::Error::NotFound
  end

  # def getProject
  #   Gitlab.configure do |c|
  #     c.endpoint = CONFIG.endpoint
  #     c.private_token = CONFIG.private_token
  #   end
  #   Gitlab.client
  #
  # end



end
