class Commit
  def self.from_git_log_item(string)
    new string
  end

  def initialize(string)
    @string = string
  end

  def message
    @string.split("\n\n", 2)[1].gsub(/(^|\n)    /, '\1')
  end
end
