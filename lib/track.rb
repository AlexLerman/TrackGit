require 'pivotaltracker'
require 'jira-ruby'
require 'github'


class Track
  @tracker = config.tracker
  @project = getProject()
  @user = getUser()
  @branch = getBranchName()

  public
  def createIssue(title, body = nil, asssignee = nil, milestone = nil, labels = nil)
    case @tracker
    when "github"
      @project.create_issue( config.repo, title: title, body: body, {:assignee => assignee, milestone: milestone, labels: labels})
    when "jira"
    when "pivotaltracker"
    else
      puts "Issue tracker not supported yet"
    end
  end

  def addComment(comment)
    @project.add_comment(config.repo, getIssue().number,  comment)
  end

  def addTask(task)
    #not for github
  end

  def getIssue(name)
    issues = @project.issues(config.repo)
    issues.detect {|i| convertToValidBranchName(i.title) == @branch}
  end

  def resolveIssue(issue)
  end

  def listIssues
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
  end

  private

  def getBranchName
    `git rev-parse --abbrev-ref HEAD`.gsub("\n", '')
  end

  def convertToValidBranchName(name)
    name.gsub(" ", '_')
  end

  def getProject

  end

  def currentIssueID

  end

end
