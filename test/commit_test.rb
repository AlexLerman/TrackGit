require 'minitest/autorun'
require_relative '../lib/commit'

class CommitTest < Minitest::Test
  def test_it_removes_cruft_from_commits_in_the_git_log
    log = <<-__
Author: Alex Lerman <alexander.a.lerman@gmail.com>
Date:   Tue Mar 1 20:41:09 2016 -0800

    Testing commit message thing

    What does this look like man?

    I mean seriously....
    __

    expected_message = <<-__
Testing commit message thing

What does this look like man?

I mean seriously....
    __

    assert_equal expected_message, Commit.from_git_log_item(log).message
  end
end
