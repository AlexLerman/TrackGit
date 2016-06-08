require 'minitest/autorun'
require_relative '../lib/configuration'

class ConfigurationTest < Minitest::Test
  def test_it_writes_to_config_using_a_setter_method
    config = Configuration.new('tmp/test_config')
    config.foo = 'bar'
    assert_equal 'bar', config.foo
  end

  def test_it_writes_to_config_using_square_brackets
    config = Configuration.new('tmp/test_config')
    config['foo'] = 'bar'
    assert_equal 'bar', config['foo']
  end

  def test_it_persists_config_in_a_file
    with_tmp_file do
      config = Configuration.new('tmp/test_config')
      config.foo = 'bar'
      assert_equal 'bar', config.foo

      config2 = Configuration.new('tmp/test_config')
      assert_equal 'bar', config2.foo
    end
  end

  def test_known_weakness_it_does_not_update_existing_instances_from_the_file
    with_tmp_file do
      config = Configuration.new('tmp/test_config')

      config.foo = 'bar'

      config2 = Configuration.new('tmp/test_config')
      config2.foo = 'asdf'

      assert_equal config.foo, 'bar'
    end
  end

  def with_tmp_file
    Dir.mkdir('tmp') unless Dir.exists? 'tmp'

    yield

    File.delete('tmp/test_config')
    Dir.rmdir('tmp')
  end
end
