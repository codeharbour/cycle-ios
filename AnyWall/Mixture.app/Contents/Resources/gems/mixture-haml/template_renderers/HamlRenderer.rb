class HamlRenderer < Renderer
    
    require 'base64'
    
    # Mixture project variables.
    @@project_vars = []
    
    
    # Output renders HAML to HTML and returns string.
    def output(project_vars)
        # Check if project_vars is set.
        if(@@project_vars.empty?)
            # Set main project vars passed in via ARGS.
            set_project_vars_from_args(project_vars)
            # Set layout_file and view_string.
            set_layout_file_and_view_string
            # Set model
            set_model
        end
        
        # Add the project vars as a HAML option so that it's available to our asset URL filter.
        Haml::Options.defaults[:project_vars] = @@project_vars
        
        # Render output string from HAML view and layout.
        output = render_haml
        
        # Catch any HAML errors and output via STDERR.
        rescue Haml::Error => error
        STDERR.puts error
        output = 'One or more errors occurred.'
        
        # Return output string.
        return output
    end
    
    # Renders HAML to HTML based on project_vars.
    def render_haml
        # Render view with associated partials.
        regions = HamlRendererRegions.new
        
        # Create view from our cleaned up view string
        view = Haml::Engine.new(@@project_vars[:view_string]).render(regions, @@project_vars[:model])
        
        # Build output string from rendered layout, view and partials.
        if @@project_vars[:layout_file] != ""
            aaa = File.read("#{@@project_vars[:template_path]}/layouts/#{@@project_vars[:layout_file]}")
            if RUBY_VERSION < "1.9"
                
                else
                aaa = aaa.force_encoding("UTF-8")
            end
            output = Haml::Engine.new(aaa).render do |region, err|
                region ? regions[region] : view
            end
            else
            output = Haml::Engine.new(@@project_vars[:view_string]).render(Object.new, @@project_vars[:model])
        end
        
        # Return output string.
        return output
    end
    
    # Set all project vars passed in via ARGS.
    def set_project_vars_from_args(project_vars)
        if(project_vars.empty?)
            raise Haml::Error.new("Missing Mixture project variables.")
            else
            project_vars_hash = {}
            
            loop { case project_vars[0]
                when '--project_path' then project_vars.shift; project_vars_hash[:project_path] = project_vars.shift
                when '--template_path' then project_vars.shift; project_vars_hash[:template_path] = project_vars.shift
                when '--model_file' then project_vars.shift; project_vars_hash[:model_file] = project_vars.shift
                when '--view_file' then project_vars.shift; project_vars_hash[:view_file] = project_vars.shift
                when '--debug' then project_vars.shift; project_vars_hash[:debug] = project_vars.shift
                else break
            end; }
            
            @@project_vars = project_vars_hash
            
        end
    end
    
    # Set the layout file var and view string.
    def set_layout_file_and_view_string
        view_string = File.read("#{@@project_vars[:template_path]}/#{@@project_vars[:view_file]}")
        if RUBY_VERSION < "1.9"
            
            else
            view_string = view_string.force_encoding("UTF-8")
        end
        match = view_string.match(/=layout :(.*?)\n/m)
        
        if match == nil
            layout_file = "none"
            else
            layout_file = match[1].strip
        end
        
        if layout_file != "none"
            if File.exist?("#{@@project_vars[:template_path]}/layouts/#{layout_file}.haml")
                @@project_vars[:layout_file] = layout_file + '.haml'
                @@project_vars[:view_string] = view_string.gsub("=layout :#{layout_file}\n",'')
                else
                raise Haml::Error.new("Layout file specified in #{@@project_vars[:view_file]} does not exist.")
            end
            else
            @@project_vars[:layout_file] = ""
            @@project_vars[:view_string] = view_string
        end
    end
    
    # Parse JSON model.
    def set_model
        b = Base64.decode64(@@project_vars[:model_file])
        @@project_vars[:model] = JSON.parse(b)
    end
    
    # Mixture include function allowing for partials to be included.
    def include(region)
    bbb = File.read("#{@@project_vars[:template_path]}/includes/_#{region}.haml")
    if RUBY_VERSION < "1.9"
    
    else
    bbb = bbb.force_encoding("UTF-8")
end
Haml::Engine.new(bbb).render(Object.new, @@project_vars[:model])
end

# Alias of include.
def render(region)
    include(region)
end

def project_vars
    @@project_vars
end

end