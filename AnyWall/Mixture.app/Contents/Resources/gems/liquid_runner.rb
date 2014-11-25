require 'liquid'
require "paginate"
require "json"

require "collection"
require "pathname"
require "grouped"
require "item"
require "archive"
require "liquid_inheritance"
require "i18n"

liquidFile = ARGV[0]
jsonFile = ARGV[1]

path = ARGV[2]
templatePath = ARGV[3]
layout = ARGV[4]
debug = ARGV[5]
ignores = ARGV[6]
I18n.enforce_available_locales = false


begin
    
    Liquid::Template.file_system = Liquid::MixtureFileSystem.new(templatePath,path,layout,debug,ignores)
    #Liquid::Template.register_filter(MixtureFilters)
    
    liquid = File.open(liquidFile, "r")
    liquidString = liquid.read
    
    if RUBY_VERSION < "1.9"
       template = Liquid::Template.parse(liquidString)
    else
        template = Liquid::Template.parse(liquidString.force_encoding("UTF-8"))
    end
    
    
    ffile = File.open(jsonFile, "r")
    data = ffile.read
    if RUBY_VERSION < "1.9"
        jsonModel = JSON.parse(data)
        else
        jsonModel = JSON.parse(data.force_encoding("UTF-8"))
    end
    
    #ffile.close
    
    #@template.render( testjson )
    puts template.render( jsonModel )

#rescue StandardError
# $stderr.print $!
    
end