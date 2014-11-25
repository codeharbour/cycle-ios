require "liquid"
#require "#{File.dirname(__FILE__)}/block"
#require "#{File.dirname(__FILE__)}/layout"
require "/Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/liquid-2.4.1/lib/MixtureFileSystem"

#Liquid::Template.register_tag(:layout, LiquidBlocks::Layout)
#Liquid::Template.register_tag(:block, LiquidBlocks::Block)
require "json"

#@template = Liquid::Template.parse(File.read('/Users/petenelson/Desktop/desktopmarch2013/susytesting/templates/modelshort.liquid'))
#dog = File.read('/Users/petenelson/Desktop/testinclude/models/index.json')
#puts @template.render(JSON.parse(pete))
#Liquid::Template.file_system = Liquid::MixtureFileSystem.new('/Users/petenelson/Desktop/epty/templates')
#Liquid::Template.file_system.full_path("includes/color")       # => "/some/path/_mypartial.liquid"
#@template = Liquid::Template.parse(File.read('/Users/petenelson/Desktop/epty/templates/testing.liquid'))

pete = File.read('/Users/petenelson/Desktop/testinclude/models/index.json')

Liquid::Template.file_system = Liquid::MixtureFileSystem.new('/Users/petenelson/Desktop/testinclude/templates')
#Liquid::Template.file_system.full_path("includes/color")       # => "/some/path/_mypartial.liquid"
@template = Liquid::Template.parse(File.read('/Users/petenelson/Desktop/testinclude/templates/index.liquid'))

puts @template.render(JSON.parse(pete))