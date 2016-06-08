require 'yaml'

class Configuration
  def initialize(filename)
    raise "filename is required" unless filename

    @storage = YAML.load_file(filename) if File.exists? filename
    @storage ||= {}
    @filename = filename

    directory = File.dirname @filename
    `mkdir -p #{directory}` if not Dir.exists? directory
  end

  def []=(key, value)
    set(key, value)
  end

  def [](key)
    get(key)
  end

  def method_missing(key, value=nil, *args_we_dont_care_about)
    if key.to_s.end_with? '='
      set(key, value)
    else
      get(key)
    end
  end

  def set(key, value)
    @storage[key.to_s.sub('=', '')] = value
    File.write(@filename, @storage.to_yaml)
  end

  def get(key)
    @storage[key.to_s]
  end
end
