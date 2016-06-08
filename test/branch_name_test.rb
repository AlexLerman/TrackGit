require 'minitest/autorun'
require_relative '../lib/branch_name'

class BranchNameTest < Minitest::Test
  def test_it_removes_trailing_slashes
    assert_equal '1_foo', BranchName.new('foo/', 1).to_branch_name
  end

  def test_it_leaves_slashes_in_the_middle_of_the_name
    assert_equal '1_make_cat/dog_parsers_work', BranchName.new('make cat/dog parsers work', 1).to_branch_name
  end

  def test_it_leaves_expressive_punctuation_in_place
    assert_equal '1_work,_dammit!', BranchName.new('work, dammit!', 1).to_branch_name
  end

  def test_it_removes_other_non_alphanumeric_characters
    assert_equal '1_hello_world', BranchName.new('hello.@#$%^&()\world', 1).to_branch_name
  end

  def test_it_raises_an_error_given_empty_string
    assert_raises do
      BranchName.new('')
    end
  end

  def test_accepts_issue_number
    assert_equal '3_work_dammit!', BranchName.new('work dammit!', 3).to_branch_name

  end

  def test_can_return_issue_number_of_properly_named_branch
    assert_equal '3', BranchName.new("3_I_hate_this", 0).get_issue_number
  end


end
