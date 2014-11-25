require 'collections_handler'

coll_hand = CollectionsHandler.new
nodebin = ARGV[0]
nodeyaml = ARGV[1]
project_root = ARGV[2]
templates = ARGV[3]
debug = ARGV[4]
ignores = ARGV[5]
puts coll_hand.run_processed(nodebin,nodeyaml,project_root,templates,debug,ignores)
	
  