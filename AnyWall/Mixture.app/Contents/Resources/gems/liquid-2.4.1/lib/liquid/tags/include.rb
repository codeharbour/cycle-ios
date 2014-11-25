module Liquid
  
    
    
    class Include < Tag
    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/o
  
    def initialize(tag_name, markup, tokens)      
      if markup =~ Syntax

        @template_name = $1

        @template_name_strip_quotes = @template_name[1..-2]
        @template_name_filename_only = Pathname.new(@template_name_strip_quotes).basename.to_s
        
        @template_name_no_quotes =  "includes/"+@template_name[1..-2]
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise SyntaxError.new("Error in tag 'include' - Valid syntax: include '[template]' (with|for) [object|collection]")
      end

      super
    end
  
    def parse(tokens)
    end
    
    def render(context)
      source = _read_template_from_file_system(context)
      

      fs = context.registers[:file_system] || Liquid::Template.file_system

      temp_temp_path = fs.get_template_path
      temp_temp_path_filename_only = Pathname.new(temp_temp_path).basename.to_s
      if RUBY_VERSION < "1.9"
          partial = Liquid::Template.parse(source)
          else
          partial = Liquid::Template.parse(source.force_encoding("UTF-8"))
          end
      

      variable = context[@variable_name || @template_name_no_quotes]
      
      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        if variable.is_a?(Array)
          idx = 0
          len = variable.length

          variable.collect do |vvar|
              #puts "tempalte is "+@template_name_strip_quotes
              #puts "context is "+context["dog"].inspect
              #puts "fff"+@template_name_strip_quotes+"fff"
              #puts "fdd"+(@template_name_filename_only == @template_name_strip_quotes)+"ffd"
              #context[@template_name_filename_only] = vvar
              context[temp_temp_path_filename_only] = vvar
              context['forloop'] = {
                #'name'    => @template_name_filename_only,
                'name'    => temp_temp_path_filename_only,
                'length'  => len,
                'index'   => idx + 1, 
                'index0'  => idx, 
                'rindex'  => len - idx,
                'rindex0' => len - idx - 1,
                'first'   => (idx == 0),
                'last'    => (idx == len - 1) 
              }
            idx = idx+1 
            partial.render(context)

          end
        else
          #context[@template_name_filename_only] = variable
          context[temp_temp_path_filename_only] = variable
          partial.render(context)
        end
      end
    end
   
    private
      def _read_template_from_file_system(context)
        file_system = context.registers[:file_system] || Liquid::Template.file_system
      
        # make read_template_file call backwards-compatible.
        case file_system.method(:read_template_file).arity
        when 1
          file_system.read_template_file(context[@template_name])
        when 2
          file_system.read_template_file(context[@template_name], context)
        else
          raise ArgumentError, "file_system.read_template_file expects two parameters: (template_name, context)"
        end
      end
  end

  Template.register_tag('include', Include)  
end
