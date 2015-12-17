require 'github'


class Track
  @project = getProject()
  @user = getUser()

  public
  def addIssue
  end

  def addComment(issue)
  end

  def addTask(issue)
  end

  def resolveIssue(issue)
  end

  def listIssues
  end

  def listAssignedIssues
  end

  def listComments
  end

  def label
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
