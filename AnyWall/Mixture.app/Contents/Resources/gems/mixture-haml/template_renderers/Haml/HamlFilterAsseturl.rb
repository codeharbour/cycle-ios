module Haml::Filters::Asseturl
    include Haml::Filters::Base
    
    def to_boolean(s)
        s and !!s.match(/^(true|t|yes|y|1)$/i)
    end
    
    def render_with_options(text, options)
        
        project_vars = options[:project_vars]
        
        file_name = "#{text.delete(' ')[/^%[a|img|link|script].*?[src|href]=.*?"(.*?)"/i,1]}"
        
        rest_of_path = File.dirname(file_name)
        name = File.basename(file_name, ".*")
        ext = File.extname(file_name)
        asset_name = name + ext
        
        if ext.empty? then
            return "Asset not found: #{asset_name}"
        end
        
        if(rest_of_path != "." || rest_of_path == "")
            asset_name = rest_of_path+ "/" + name + ext
        end
        
        file_paths = []
        
        Find.find(project_vars[:project_path]) do |path|
            dir, base = File.split(path)
            next if path.downcase.include? '/converted-html/'
            next if path.downcase.include? '/collections/'
            next if path.downcase.include? '/.'
            next if path.downcase.include? '/..'
            next if !path.include? rest_of_path
            next if !base.start_with? "#{name}"
            next if !base.end_with? "#{ext}"
            file_paths << path if base =~ /#{name}(.*)#{ext}/
        end
        
        file_path = ""
        
        if file_paths.first
            
            file_path = file_paths.find { |e| /#{asset_name}/ =~ e }
            
            if file_path == nil
                return "Asset not found: #{asset_name}"
            end
            
            debug = to_boolean(project_vars[:debug].to_s)
            
            if !debug
                if file_path.include? '.min.css'
                    file_path = file_paths.find { |e| /#{name}#{ext}/ =~ e }
                    elsif file_path.include? '.css'
                    temp_file_path = file_path.clone
                    file_path = file_paths.find { |e| /#{name}.min#{ext}/ =~ e }
                    if !file_path
                        file_path = temp_file_path
                    end
                end
                
                if file_path.include? '.min.js'
                    file_path = file_paths.find { |e| /#{name}#{ext}/ =~ e }
                    elsif file_path.include? '.js'
                    temp_file_path = file_path.clone
                    file_path = file_paths.find { |e| /#{name}.min#{ext}/ =~ e }
                    if !file_path
                        file_path = temp_file_path
                    end
                end
            end
            
            Haml::Engine.new(text.gsub(/#{asset_name}/, file_path.gsub(project_vars[:project_path],''))).render(Object.new, project_vars[:model])
            else
            "Asset not found: #{asset_name}"
        end
    end
end