require 'minitest/autorun'
require_relative '../lib/branch_name'

class BranchNameTest < Minitest::Test
  def test_it_removes_trailing_slashes
    assert_equal 'foo', BranchName.new('foo/').to_s
  end

  def test_it_leaves_slashes_in_the_middle_of_the_name
    assert_equal 'make_cat/dog_parsers_work', BranchName.new('make cat/dog parsers work').to_s
  end

  def test_it_leaves_expressive_punctuation_in_place
    assert_equal 'work,_dammit!', BranchName.new('work, dammit!').to_s
  end

  def test_it_removes_other_non_alphanumeric_characters
    assert_equal 'hello_world', BranchName.new('hello.@#$%^&()\world').to_s
  end

  def test_it_raises_an_error_given_empty_string
    assert_raises do
      BranchName.new('')
    end
  end

  def test_accepts_issue_number
    assert_equal '3_work_dammit!', BranchName.new('work dammit!', 3).to_s

  end


end
