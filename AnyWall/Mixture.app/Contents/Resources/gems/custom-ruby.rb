
gem_path = ARGV[0]
sass_file = ARGV[1]
sass_type = ARGV[2]
line_numbers = ARGV[3]
debug_info = ARGV[4]
source_map = ARGV[5]
cache = ARGV[6]
globbing = ARGV[7]

output_style = ARGV[8]
cache_location = ARGV[9]+"/.sass-cache"
sourcemap_filename = ARGV[10]+".map"
output_path = ARGV[10]
gem_home = ARGV[11]

if output_style == ""
    output_style = eval(":nested")
    else
    output_style = eval(":" + output_style)
end

source_map = eval(source_map)

require 'rubygems';


#raise gem_path
begin
    
    if gem_path != "mixturegems"
        
        gem_paths_array = gem_path.split(':')
        
        Gem.use_paths(gem_home,gem_paths_array)
        Gem.refresh #
    end
    require 'sass'
    if(eval(globbing))
        require 'sass-globbing';
    end
    sass_options = {
        
        :line_numbers => eval(line_numbers),
        :debug_info => eval(debug_info),
        :cache => eval(cache),
        :cache_location => cache_location,
        :quiet => true,
        :style => output_style
    }
    
    if source_map
        sass_options[:source_map] = source_map
        sass_options[:sourcemap_filename] = sourcemap_filename
        
    end
    
    
    
    #file = File.open(sass_file, "r")
    #contents = file.read
    #file.close
    
    begin
        engine = Sass::Engine.for_file(sass_file, sass_options)
        if source_map
            
            relative_sourcemap_path = Pathname.new(sourcemap_filename).
            relative_path_from(Pathname.new(output_path).dirname)
            
            rendered, mapping = engine.render_with_sourcemap(relative_sourcemap_path.to_s)
            
            maps =  mapping.to_json(:css_path => output_path,:sourcemap_path => sourcemap_filename)
            
            #puts rendered_array[1].inspect
            File.open(sourcemap_filename, 'w') { |file| file.write(maps) }
            
            else
            rendered =  engine.render
            
            
        end
        puts rendered
        rescue Exception => e
        
        if e.class.name == "Sass::SyntaxError"
            puts "mixture_sass_error"+e.sass_backtrace_str
            else
            puts "mixture_sass_error"+e.inspect
        end
        
    end
    
end
