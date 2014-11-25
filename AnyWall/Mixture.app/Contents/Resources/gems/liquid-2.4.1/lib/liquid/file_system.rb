module Liquid
  # A Liquid file system is way to let your templates retrieve other templates for use with the include tag.
  #
  # You can implement subclasses that retrieve templates from the database, from the file system using a different 
  # path structure, you can provide them as hard-coded inline strings, or any manner that you see fit.
  #
  # You can add additional instance variables, arguments, or methods as needed.
  #
  # Example:
  #
  # Liquid::Template.file_system = Liquid::LocalFileSystem.new(template_path)
  # liquid = Liquid::Template.parse(template)
  #
  # This will parse the template with a LocalFileSystem implementation rooted at 'template_path'.
  class BlankFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(template_path, context)
      raise FileSystemError, "This liquid context does not allow includes."
    end
  end
  
  # This implements an abstract file system which retrieves template files named in a manner similar to Rails partials,
  # ie. with the template name prefixed with an underscore. The extension ".liquid" is also added.
  #
  # For security reasons, template paths are only allowed to contain letters, numbers, and underscore.
  #
  # Example:
  #
  # file_system = Liquid::LocalFileSystem.new("/some/path")
  # 
  # file_system.full_path("mypartial")       # => "/some/path/_mypartial.liquid"
  # file_system.full_path("dir/mypartial")   # => "/some/path/dir/_mypartial.liquid"
  #
  class LocalFileSystem
    attr_accessor :root
    
    def initialize(root)
      @root = root
    end
    
    def read_template_file(template_path, context)
      full_path = full_path(template_path)
      raise FileSystemError, "No such template '#{template_path}'" unless File.exists?(full_path)
      
      File.read(full_path)
    end
    
    def full_path(template_path)
      raise FileSystemError, "Illegal template name '#{template_path}'" unless template_path =~ /^[^.\/][a-zA-Z0-9_\/]+$/
      
      full_path = if template_path.include?('/')
        File.join(root, File.dirname(template_path), "_#{File.basename(template_path)}.liquid")
      else
        File.join(root, "_#{template_path}.liquid")
      end
      
      raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /^#{File.expand_path(root)}/
      
      full_path
    end
  end

class MixtureFileSystem
    attr_accessor :root
    attr_accessor :debug
    attr_accessor :index_path
    attr_accessor :template_path
    attr_accessor :default_template
    attr_accessor :ignores
    
    #template path then the root path of the project tand then debug
    def initialize(template_pa, index_path = "",default_template="", debug = false, ignores = "")
        @root = template_pa
        @debug = debug
        @index_path = index_path
        @default_template = default_template
        
        if(ignores.include? ',')
            @ignores = ignores.split(",")
        elsif (ignores == 'ignores')
            @ignores = ["mixture-ignore-ignores"]
        elsif (ignores == '')
            @ignores = ["mixture-ignore-ignores"]
        else
            @ignores = []
            @ignores[0] = ignores;
        end
        
    end
    
    def read_index_file
        
        if @index_path == ""
            ""
            else
            File.read(File.join(@index_path,"collections",".cache","indexed.json"))
        end
        
    end
    
    def get_template_path
        @template_path
    end
    
    def read_template_file(template_path, context)
        
        
        
        if(template_path.start_with?("../"))
            raise FileSystemError, "No such template '#{template_path}'"
        end
        
        @template_path = template_path
        
        
        full_path = full_path(template_path)
        
        raise FileSystemError, "No such template '#{template_path}'" unless File.exists?(full_path)
        
        File.read(full_path)
    end
    
    def full_path(template_path)
        #raise FileSystemError, "Illegal template name '#{template_path}'" unless template_path =~ /^[^.\/][a-zA-Z0-9_\/]+$/
        
        #full_path = if template_path.include?('/')
        #File.join(root, File.dirname(template_path), "includes/#{template_path}.liquid")
        #else
        
        if template_path.start_with?('layouts/')
            
            full_path = File.join(root, "#{template_path}.liquid")
            
            else
            
            full_path = File.join(root, "includes/#{template_path}.liquid")
        end
        
        
        #raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path) =~ /^#{File.expand_path(root)}/
        
        full_path
    end
end

end