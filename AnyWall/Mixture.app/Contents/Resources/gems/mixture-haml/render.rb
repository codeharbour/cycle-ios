# Define absolute path.
#ABS_PATH = Dir.pwd
ABS_PATH = File.dirname(__FILE__)
#puts ABS_PATH

# Fixes for various versions of Ruby.
# Ensures compatability with 1.8.x and >=1.9.2
#$LOAD_PATH.unshift ABS_PATH + "/lib" unless $LOAD_PATH.include?(ABS_PATH + "/lib")
#require ABS_PATH + '/lib/haml.rb'
#require ABS_PATH + '/lib/json.rb'
require 'haml'
require 'json'
require 'kramdown'
require ABS_PATH + '/Renderer.rb'
require ABS_PATH + '/template_renderers/HamlRenderer.rb'
require ABS_PATH + '/template_renderers/Haml/HamlRendererRegions.rb'
require ABS_PATH + '/template_renderers/Haml/HamlFilterAsseturl.rb'
require ABS_PATH + '/template_renderers/Haml/HamlOptions.rb'
require 'find'

project_vars = ARGV

# Call Renderer factory with template renderer defined and pass
# in project vars.
output = Renderer.factory(:haml).output(project_vars)

# Output
STDOUT.puts output