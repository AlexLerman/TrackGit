# require 'pivotaltracker'
# require 'jira-ruby'
require 'octokit'
require_relative './configure'
require_relative './branch_name'

class Track

  def initialize
    @branch = getCurrentBranchName()
  end

  public

  def getCurrentIssue
    findIssue(@branch)
  end

  def commentAndClose(branch, comment)
    addComment(comment, findIssue(branch).number)
    resolveIssue(branch)
  end


  def setTracker(tracker = "github")
    CONFIG.tracker = tracker
  end


  def setRepo(repo)
    CONFIG.repo = repo
  end

  def getCurrentBranchName
    `git rev-parse --abbrev-ref HEAD`.gsub("\n", '')
  end

  def currentIssueID
    getIssue().number
  end

end
