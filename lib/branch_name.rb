class BranchName
  def initialize(string, issueNumber)
    raise "Branch names cannot be empty" if string.empty?
    @raw_branch_name = string
    @issue_number = issueNumber
  end

  def to_s
    @raw_branch_name.gsub(/\/$/, '').gsub(/[^A-Za-z0-9\!\?\-\_\/\,]+/, '_')
  end

  def to_branch_name
    @issue_number.to_s + "_" + to_s
  end

  def to_issue_name
    @raw_branch_name.split("_", 2)[1]
  end

  def get_issue_number
    @raw_branch_name.split("_", 2)[0]
  end
end
