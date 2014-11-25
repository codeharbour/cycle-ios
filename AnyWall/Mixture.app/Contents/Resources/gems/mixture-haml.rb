require 'haml'
require 'json'

template = ARGV[0]
json = ARGV[1]
modelObject = JSON.parse json
haml_engine = Haml::Engine.new(template, :attr_wrapper => '"')
puts haml_engine.render(Object.new, modelObject)