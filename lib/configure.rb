require_relative './configuration'
require 'yaml'

repo = File.basename( `git rev-parse --show-toplevel`.chomp)

CONFIG_FILE_PATH = File.join(ENV['HOME'], '.config', 'trackgit' , repo)
CONFIG_FILE_NAME = 'config.yml'

CONFIG = Configuration.new(File.join(CONFIG_FILE_PATH, CONFIG_FILE_NAME))




# `mkdir -p #{CONFIG_FILE_PATH}` if not Dir.exists? CONFIG_FILE_PATH
#
# File.write(File.join(CONFIG_FILE_PATH, CONFIG_FILE_NAME), "") if not File.exists?(File.join(CONFIG_FILE_PATH,CONFIG_FILE_NAME))





# hash = YAML::load_file(File.join(CONFIG_FILE_PATH, CONFIG_FILE_NAME))
# hash = hash ? hash : {}
# configatron.configure_from_hash(hash)
# configatron.location = File.join(CONFIG_FILE_PATH, CONFIG_FILE_NAME)
