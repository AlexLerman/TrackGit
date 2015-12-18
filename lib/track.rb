require 'github'
require 'pivotaltracker'
require 'jira-ruby'

class Track
  @tracker = config.tracker
  @project = getProject()
  @user = getUser()

  public
  def createIssue(name)
    case @tracker
    when "github"
      github.issue.create("name")
    when "jira"
    when "pivotaltracker"
    else
      puts "Issue tracker not supported yet"
    end
  end

  def addComment(comment)
  end

  def addTask(task)
    #not for github
  end

  def getIssue(name)
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

  def getProject

  end


end
