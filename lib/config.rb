require 'configatron'
require 'yaml'

CONFIG_FILE_PATH = File.join(ENV['HOME'], '.config', 'trackgit')
CONFIG_FILE_NAME = 'config.yml'
`mkdir -p #{CONFIG_FILE_PATH}` if not Dir.exists? CONFIG_FILE_PATH

File.write(File.join(CONFIG_FILE_PATH, CONFIG_FILE_NAME), "") if not File.exists?(File.join(CONFIG_FILE_PATH,CONFIG_FILE_NAME))
hash = YAML::load_file(File.join(CONFIG_FILE_PATH, CONFIG_FILE_NAME))
hash = hash ? hash : {}
configatron.configure_from_hash(hash)
