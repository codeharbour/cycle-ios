gem_path = ARGV[0]
compass_path = ARGV[1]
gem_home = ARGV[2]
require 'rubygems';
#raise gem_path
begin
    gem_paths_array = gem_path.split(':')
    
    Gem.use_paths(gem_home,gem_paths_array)
    Gem.refresh #
    require 'compass'
    require 'sass/plugin'
    require 'compass/sass_compiler'
    fixed_options = {
        :color_output => false
        
    }
    Compass.add_project_configuration compass_path
    Compass.add_configuration(fixed_options, "custom")
    Compass.sass_compiler.compile!
    
end