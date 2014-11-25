
module Liquid
    class Collection < Liquid::Block
        
        SyntaxNoPage = /(#{Liquid::QuotedFragment})?/
        SyntaxNoPageOrder = /(#{Liquid::QuotedFragment})\s*order\s+(.*)?/o
        SyntaxNoPageQuery = /(#{Liquid::QuotedFragment})\s*query\s+(#{QuotedFragment}+)?/o
        SyntaxNoPageQueryOrder = /(#{Liquid::QuotedFragment})\s*query\s+(#{QuotedFragment}+)\s+order\s+(.*)?/o
        
        Syntax = /(#{Liquid::QuotedFragment})\s*by\s*(\d+)?/
        SyntaxOrder = /(#{Liquid::QuotedFragment})\s*by\s*(\d+)\s+order\s+(.*)?/o
        SyntaxQuery = /(#{Liquid::QuotedFragment})\s*by\s*(\d+)\s+query\s+(#{QuotedFragment}+)?/o
        SyntaxQueryOrder = /(#{Liquid::QuotedFragment})\s*by\s*(\d+)\s+query\s+(#{QuotedFragment}+)\s+order\s+(.*)?/o
        
        def initialize(tag_name, markup, tokens)
            
            @nodelist = []
            @asc_desc = "desc"
            @query_hash = Hash.new
            
            if markup =~ SyntaxQueryOrder
                @collection_name_without_quotes = $1[1..-2]
                @page_size = if $2
                $2.to_i
                else
                20
            end
            
            @collection_name = @collection_name_without_quotes
            
            @query = $3[1..-2]
            
            @asc_desc = $4.strip == "asc" ? "asc" : "desc"
            
            
            elsif markup =~ SyntaxQuery
            @collection_name_without_quotes = $1[1..-2]
            @page_size = if $2
            $2.to_i
            else
            20
        end
        
        @collection_name = @collection_name_without_quotes
        
        @query = $3[1..-2]
        
        
        elsif markup =~ SyntaxOrder
        @collection_name_without_quotes = $1[1..-2]
        @page_size = if $2
        $2.to_i
        else
        20
    end
    
    @collection_name = @collection_name_without_quotes
    
    @asc_desc = $3.strip == "asc" ? "asc" : "desc"
    
    
    elsif markup =~ Syntax
    @collection_name_without_quotes = $1[1..-2]
    @page_size = if $2
    $2.to_i
    else
    20
end

@collection_name = @collection_name_without_quotes
elsif markup =~ SyntaxNoPageQueryOrder
@collection_name_without_quotes = $1[1..-2]

@collection_name = @collection_name_without_quotes

@query = $2[1..-2]



@asc_desc = $3.strip == "asc" ? "asc" : "desc"


elsif markup =~ SyntaxNoPageQuery
@collection_name_without_quotes = $1[1..-2]


@collection_name = @collection_name_without_quotes

@query = $2[1..-2]






elsif markup =~ SyntaxNoPageOrder
@collection_name_without_quotes = $1[1..-2]


@collection_name = @collection_name_without_quotes

@asc_desc = $2.strip == "asc" ? "asc" : "desc"

elsif markup =~ SyntaxNoPage

@collection_name_without_quotes = $1[1..-2]

@collection_name = @collection_name_without_quotes

else
raise SyntaxError.new("Syntax Error in tag 'collection' - Valid syntax: collection \"name\" by number query \"tag=test\" order asc|desc")

end

if @page_size and @page_size > 128
    raise SyntaxError.new("Syntax Error in tag 'collection' - Maximum items per page: 128")
end

super
end

def render(context)
    @context = context
    #case insensitive
    #if @query
    #@query = @query.downcase
    #end
    
    
    indexing = _read_index_from_file_system(context)
    
    if !indexing
        raise SyntaxError.new("Syntax Error in tag 'Collection' - no collection data could be found in this project")
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
                
                zz = tt[0]
                @query = @query.gsub(/\{\{\s*#{zz}\s*\}\}/,context[tt[0]])
                
                else
                zz = tt[0]
                @query = @query.gsub(/\{\{\s*#{zz}\s*\}\}/,"")
                
            end
            
            #puts tt[0].inspect
        end
        
        #now break apart query string
        #u = URI.parse(@query)
        if RUBY_VERSION < "1.9"
            @query.split(/&/).inject({}) do |hash, setting|
                key, val = setting.split(/=/)
                hash[key] = val.to_s
                @query_hash = hash
            end
            else
            @query.split(/&/).inject({}) do |hash, setting|
                key, val = setting.split(/=/)
                if val.to_s == "true"
                    hash[key] = true
                    elsif val.to_s == "false"
                    hash[key] = false
                    else
                    hash[key] = val.to_s
                end
                
                @query_hash = hash
            end
        end
        
        
        #$stderr.puts @query_hash.to_s
        #@query_hash = nil
        
        
        #$stderr.puts @query_hash.to_s
        #$stderr.puts "--"+@query.inspect+"--"
        
        empty_query = true
        
        if @query_hash
            @query_hash.each do |hh|
                hh[1].to_s.scan(/./).each do |val|
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
        
        mm = @query_hash["month"]
        yy = @query_hash["year"]
        if RUBY_VERSION < "1.9"
            mm = @query_hash["month"][0]
            yy = @query_hash["year"][0]
        end
        
        
        #take month+year into consideration first and then strip them from query hash so other params can be checked - note these come through as an array but we'll only consider the first
        if mm != nil and yy != nil
            
            test_month_year = mm + "/" + yy
            
            matching_key = relevant_index["mixture_month_year"]
            
            if matching_key
                if(matching_key[test_month_year])
                    
                    all_arrays.push(matching_key[test_month_year])
                    
                end
            end
            #now remove month and year from the query_hash so does not interfere
            @query_hash.delete "month"
            @query_hash.delete "year"
        end
        
        @query_hash.each do |hh|
            #if there is a value
            
            if hh[1] == true
                matching_key = relevant_index[hh[0]]
                
                if matching_key
                    
                    if(matching_key["true"])
                        all_arrays.push(matching_key["true"])
                        
                    end
                    
                end
                elsif hh[1] == false
                matching_key = relevant_index[hh[0]]
                
                if matching_key
                    
                    if(matching_key["false"])
                        all_arrays.push(matching_key["false"])
                        
                    end
                    
                end
                elsif !hh[1].empty?
                matching_key = relevant_index[hh[0]]
                transliterated_matching_key = relevant_index["transliterated-"+hh[0]]
                
                if matching_key
                    
                    if (hh[1].is_a? String and matching_key[hh[1].downcase])
                        all_arrays.push(matching_key[hh[1].downcase])
                        
                        elsif(hh[1].is_a? String and transliterated_matching_key[hh[1].downcase])
                        
                        all_arrays.push(transliterated_matching_key[hh[1].downcase])
                        else
                        
                        hh[1].to_s.scan(/./).each do |val|
                            
                            if(matching_key[val.downcase])
                                all_arrays.push(matching_key[val.downcase])
                                elsif(transliterated_matching_key[val.downcase])
                                
                                all_arrays.push(transliterated_matching_key[val.downcase])
                            end
                        end
                    end
                end
            end
        end
        keys_intersect = all_arrays.inject{|codes,x| codes & x }
        if keys_intersect != nil
            keys_intersect.each do |kk|
                
                matched_collection[kk] = relevant_collection[kk]
                
            end
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
        
        current_page = 1
        if context['request.query.page']
            current_page =  context['request.query.page'].to_i
            elsif context['mixture.route.page']
            current_page =  context['mixture.route.page'].to_i
        end
        
        
        
        
        if(!@page_size)
            
            collection = {
                'page_size'      => 0,
                'current_page'   => 0,
                'current_offset' => 0,
                'size' => matched_collection.size,
                'pages' => 0,
                'previous' => false,
                'next' => false,
                'items' => matched_collection_values
            }
            context['collection'] = collection
            else
            from = (current_page - 1) * @page_size
            to = (from + @page_size) - 1
            collection = {
                'page_size'      => @page_size,
                'current_page'   => current_page,
                'current_offset' => from
            }
            
            context['collection'] = collection
            
            collection_size  = matched_collection.size
            
            #raise ArgumentError.new("Cannot paginate array '#{@collection_name}'. Not found.") if collection_size.nil?
            
            page_count = (collection_size.to_f / @page_size.to_f).to_f.ceil
            
            collection['items']      = matched_collection_values[from..to]
            collection['size'] = collection_size
            collection['pages']      = page_count
            collection['previous']   =  1 < current_page
            collection['next']       =  page_count > current_page
            
        end
        
        counter = context.environments.first["collection_instance"] ||= 0
        context.environments.first["collection_instance"] = counter + 1
        if counter > 2
            raise SyntaxError.new("Syntax Error 'Collection' tag cannot be used more than 3 times on a page")
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

Liquid::Template.register_tag('collection', Collection)

end

