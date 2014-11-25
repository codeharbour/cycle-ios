module Liquid
    class Grouped < Liquid::Block
        Syntax = /(#{Liquid::QuotedFragment})\s*by\s*(#{QuotedFragment})?/
        
        def initialize(tag_name, markup, tokens)
            @nodelist = []
            
            if markup =~ Syntax
                
                @collection_name_without_quotes = $1[1..-2]
                @grouping_without_quotes = $2[1..-2]
                @collection_name = @collection_name_without_quotes
                
            else
                raise SyntaxError.new("Syntax Error in tag 'Grouped' - Grouped collection name missing")
        
            end
            super
        end
    
    def render(context)
        @context = context
        indexing = _read_index_from_file_system(context)
               
       if RUBY_VERSION < "1.9"
           relevant_collection_and_index = JSON.parse(indexing)[@collection_name]
           else
           relevant_collection_and_index = JSON.parse(indexing.force_encoding("UTF-8"))[@collection_name]
       end
        if !relevant_collection_and_index
            return ""
        end
        relevant_collection = relevant_collection_and_index["collection"]
        
        relevant_index = relevant_collection_and_index["index"]
        
        grouped = {}

        grouped_items = Array.new
       
        context.stack do
            
            if @grouping_without_quotes == "date"
                
                relevant_index["mixture_month_year"].each do |mmyy|

                    each_item = Hash.new
                    
                    #format is mm/yyyy 
                    each_item["month"] = mmyy[0].split('/')[0]
                    each_item["year"] = mmyy[0].split('/')[1]
                    each_item["date"] = Time.utc mmyy[0].split('/')[1],mmyy[0].split('/')[0], 1 
                    
                    
                    #need to filter out unpublished by looking up by url
                    all = Array.new
                    mmyy[1].each { |it|
                        
                        curr= relevant_collection[it]
                        
                        if(curr != nil &&  curr["published"])
                            all.push(curr)
                        end
                    }
                    
                    
                    each_item["count"] =  all.size #mmyy[1].size
                    
                    
                    grouped_items.push(each_item)

                end

            else
                relevant_index[@grouping_without_quotes].each do |grr|

                    each_item = Hash.new
                    
                    each_item["name"] = grr[0]
                    
                    #need to filter out unpublished by looking up by url
                    all = Array.new
                    grr[1].each { |it|
                        
                        curr= relevant_collection[it]
                        
                        if(curr != nil &&  curr["published"])
                            all.push(curr)
                        end
                    }
                    
                    
                    each_item["count"] =  all.size 
                    
                    #each_item["count"] =  grr[1].size
                    
                    grouped_items.push(each_item)

                end
            end
            order_by_field = @grouping_without_quotes == "date" ? "date" : "count"
            ordered_grouped = order_by_field == "date" ? grouped_items.sort_by { |k| k[order_by_field]}.reverse : grouped_items.sort_by { |k| k[order_by_field]}.reverse
            context['grouped'] = grouped
            
            grouped['items']  = ordered_grouped
            
            counter = context.environments.first["grouped_instance"] ||= 0
            context.environments.first["grouped_instance"] = counter + 1
            if counter > 4
                raise SyntaxError.new("Syntax Error 'Grouped' tag cannot be used more than 5 times on a page")
            end
            
            render_all(@nodelist, context)
        end

    end
    
    private
    
      def _read_index_from_file_system(context)
        file_system = context.registers[:file_system] || Liquid::Template.file_system
        file_system.read_index_file
      end
    
    
    
end

Liquid::Template.register_tag('grouped', Grouped)

end 
    
