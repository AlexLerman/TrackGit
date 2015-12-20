require 'configatron'
require 'yaml'


hash = YAML::load_file(File.join( __dir__, 'config.yml'))
hash = hash ? hash : {}
configatron.configure_from_hash(hash)
config = configatron
