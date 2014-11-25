module Liquid
    class Paginate < Liquid::Block
        Syntax     = /(#{Liquid::QuotedFragment})\s*(by\s*(\d+))?/
        
        def initialize(tag_name, markup, tokens)
            @nodelist = []
            
            if markup =~ Syntax
                @collection_name = $1
                @page_size = if $2
                                $3.to_i
                            else
                                20
                            end
            
                @attributes = { 'window_size' => 3 }
                markup.scan(Liquid::TagAttributes) do |key, value|
                @attributes[key] = value
            end
            else
            raise SyntaxError.new("Syntax Error in tag 'paginate' - Valid syntax: paginate [collection] by number")
        end
        
        super
    end
    
    def render(context)
        @context = context
        
        context.stack do
            #current_page  = context['current_page'].to_i
            current_page = 1
            if context['request.query.page'].to_i > 0
                current_page =  context['request.query.page'].to_i
            end
            #if !current_page
            #current_page = 1
            
            from = (current_page - 1) * @page_size
            to = (from + @page_size) - 1
            
            
            pagination = {
                'page_size'      => @page_size,
                'current_page'   => current_page,
                'current_offset' => from
            }
            
            context['paginate'] = pagination
            
            collection_size  = context[@collection_name].size
            
            #raise ArgumentError.new("Cannot paginate array '#{@collection_name}'. Not found.") if collection_size.nil?
            
            page_count = (collection_size.to_f / @page_size.to_f).to_f.ceil 
           
            pagination['items']      = context[@collection_name][from..to]
            pagination['size'] = collection_size
            pagination['pages']      = page_count 
            pagination['previous']   =  1 < current_page
            pagination['next']       =  page_count > current_page
            
            
            render_all(@nodelist, context)
        end
    end
    
    #private
    
    
end

Liquid::Template.register_tag('paginate', Paginate)

end 
    
