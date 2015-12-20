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

    puts @tracker
    case @tracker
    when "github"
      @project.create_issue(configatron.repo, title, body, {:assignee => assignee, :milestone => milestone, :labels => labels})
    when "jira"
    when "pivotaltracker"
    else
      puts "Issue tracker not supported yet"
    end
  end

  def addComment(comment)
    @project.add_comment(configatron.repo, getIssue().number,  comment)
  end

  def addTask(task)
    #not for github
  end

  def getIssue
    issues = @project.issues(configatron.repo)
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

  def setTracker(tracker = "github")
    configatron.tracker = tracker
    File.write(File.join( __dir__, 'config.yml'), configatron.to_h.to_yaml)
  end

  def signInWithCredentials(user, password)
    case @tracker
    when "github"
      configatron[@tracker].login = user
      configatron[@tracker].password = password
      puts configatron.to_h.to_yaml
      File.write(File.join( __dir__, 'config.yml'), configatron.to_h.to_yaml)
    end
  end


  def setRepo(repo)
    configatron.repo = repo
    File.write(File.join( __dir__, 'config.yml'), configatron.to_h.to_yaml)
  end


  private

  def getBranchName
    `git rev-parse --abbrev-ref HEAD`.gsub("\n", '')
  end

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
