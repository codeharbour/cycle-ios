module Liquid
    class Item < Liquid::Block
        
        SyntaxOrder = /order\s+(.*)?/o
        SyntaxQuery = /query\s+(#{QuotedFragment}+)?/o
        SyntaxQueryOrder = /query\s+(#{QuotedFragment}+)\s+order\s+(.*)?/o

        def initialize(tag_name, markup, tokens)
            
            @nodelist = []
            @asc_desc = "desc" 
            

            if markup =~ SyntaxQueryOrder
                
                @query = $1[1..-2]


                @asc_desc = $2.strip == "asc" ? "asc" : "desc"


            elsif markup =~ SyntaxQuery
                

                
                @query = $1[1..-2]

                

            elsif markup =~ SyntaxOrder
                
                @asc_desc = $1.strip == "desc" ? "desc" : "asc"
              
                
            else
            raise SyntaxError.new("Syntax Error in tag 'Item' - Valid syntax: order 'field' asc|desc")

        end

        super
    end
    
    def render(context)
        
        @context = context
        #case insensitive
        #if @query 
          #  @query = @query.downcase
        #end
        
        @collection_name = context["mixture.url"].split('/').first
        
        if context["mixture.url"] == nil
            raise SyntaxError.new("Syntax Error 'Item' tag cannot be used here")
        end
        url = "/"+context["mixture.url"]
        
        indexing = _read_index_from_file_system(context)
        if !indexing
            raise SyntaxError.new("Syntax Error in tag 'Item' - no collection data could be found in this project")
        end
        if RUBY_VERSION < "1.9"
            relevant_collection_and_index = JSON.parse(indexing)[@collection_name]
            else
            relevant_collection_and_index = JSON.parse(indexing.force_encoding("UTF-8"))[@collection_name]
        end
        
        if !relevant_collection_and_index
            return ""
        end
        
        
        relevant_collection = relevant_collection_and_index["collection"]
        
        matched_collection = Hash.new
        
        testing = ""
        
        if @query
            #substitute mixture tags in the query
            matching_tags = @query.scan(/\{\{\s*(.*?)\s*\}\}/)
            
            #replace with variable if there is one
            matching_tags.each do |tt|
                
                
                if context[tt[0]]
                    @query = @query.gsub(/\{\{\s*#{tt}\s*\}\}/,context[tt[0]])
                    else
                    @query = @query.gsub(/\{\{\s*#{tt}\s*\}\}/,"")
                end
                
                #puts tt[0].inspect
            end
            
            #now break apart query string
            @query_hash = CGI::parse(@query)
            
            #puts "--"+@query.inspect+"--"
            
            empty_query = true
            
            if @query_hash
                @query_hash.each do |hh|
                    hh[1].each do |val|
                        if !val.empty?
                            
                            empty_query = false
                        end
                    end
                end
            end
        else
            matched_collection = relevant_collection
        
        end
        #if there was a query but no paramters supplied then just show all
        if empty_query
            matched_collection = relevant_collection
            elsif @query_hash and @query_hash.size > 0
            #filter by the index
            relevant_index = relevant_collection_and_index["index"]
            all_arrays = Array.new
            
            @query_hash.each do |hh|
                #if there is a value
                if !hh[1].empty?
                    matching_key = relevant_index[hh[0]]
                    
                    if matching_key
                        hh[1].each do |val|
                            
                            if(matching_key[val])
                                all_arrays.push(matching_key[val])
                                
                            end
                        end
                    end
                end
            end
            keys_intersect = all_arrays.inject{|codes,x| codes & x }
            keys_intersect.each do |kk|
                
                matched_collection[kk] = relevant_collection[kk]
                
            end
            else
            matched_collection = relevant_collection
        end
        
        not_published = Array.new
        #remove any not published
        matched_collection.each do |ii|
            
            if !ii[1]["published"]
                not_published.push(ii[0])
            end
        end
        
        not_published.each do |rem|
            matched_collection.delete(rem)
        end
        
        order_by_field = "date"
        matched_collection_values = @asc_desc == "desc" ? matched_collection.values.sort_by { |k| DateTime.parse(k[order_by_field])}.reverse : matched_collection.values.sort_by { |k| DateTime.parse(k[order_by_field]) }
        
        context.stack do
            
            postItem = matched_collection[url]
            
            previous_item = nil
            next_item = nil
            
            found = false
            
            matched_collection_values.each do |uu|
                if found
                    previous_item = Hash.new
                    previous_item["url"] = uu["slug"].clone
                    previous_item["date"] = uu["date"]
                    previous_item["title"] = uu["title"].clone
                    
                    break
                end
                if uu["slug"] == url
                    found = true
                end
                if !found
                    next_item = Hash.new
                    next_item["url"] = uu["slug"].clone
                    next_item["date"] = uu["date"]
                    next_item["title"] = uu["title"].clone
                    
                    
                end
            end

            #if we are on an item page
            if found
                context['previous']   =  previous_item
                context['next']       =  next_item
            end
            
            counter = context.environments.first["item_instance"] ||= 0
            context.environments.first["item_instance"] = counter + 1
            if counter > 0
                raise SyntaxError.new("Syntax Error 'Item' tag cannot be used more than once on a page")
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

Liquid::Template.register_tag('item', Item)

end 
    
