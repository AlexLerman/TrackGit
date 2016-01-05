class BranchName
  def initialize(string)
    raise "Branch names cannot be empty" if string.empty?
    @raw_branch_name = string
  end

  def to_s
    @raw_branch_name.gsub(/\/$/, '').gsub(/[^A-Za-z0-9\!\?\-\_\/\,]+/, '_')
  end
end
