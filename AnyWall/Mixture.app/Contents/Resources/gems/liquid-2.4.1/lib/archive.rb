module Liquid
    class Archive < Liquid::Block
        Syntax = /(#{QuotedFragment})?/
        
        def initialize(tag_name, markup, tokens)
            @nodelist = []
            
            if markup =~ Syntax
                
                @collection_name_without_quotes = $1[1..-2]
                @collection_name = @collection_name_without_quotes
                
                else
                raise SyntaxError.new("Syntax Error in tag 'Archive' - Archive collection name missing")
                
            end
            super
        end
        
        def render(context)
            @context = context
            indexing = _read_index_from_file_system(context)
            
            if !indexing
                raise SyntaxError.new("Syntax Error in tag 'Archive' - no collection data could be found in this project")
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
            
            relevant_index = relevant_collection_and_index["index"]
            
            archive = {}
            
            items = Array.new
            
            context.stack do
                
                
                relevant_index["year"].each do |yy|
                    
                    each_item = Hash.new
                    
                    each_item["year"] = yy[0]
                    
                    each_item["children"] = Array.new
                    
                    yy[1].each do |child|
                        cc = relevant_collection[child]
                        chil = Hash.new
                        chil["title"] = cc["title"]
                        chil["date"] = cc["date"]
                        chil["slug"] = cc["slug"]
                        if cc["published"]
                            each_item["children"].push(chil)
                        end
                    end
                    
                    each_item["count"] =  each_item["children"].size
                    each_item["children"] = each_item["children"].sort_by { |k| Date.parse(k["date"])}.reverse
                    items.push(each_item)
                    
                end
                
                archive["items"] = items.sort_by { |k| k["year"]}.reverse
                
                
                
                context['archive'] = archive
                
                counter = context.environments.first["archive_instance"] ||= 0
                context.environments.first["archive_instance"] = counter + 1
                if counter > 0
                    raise SyntaxError.new("Syntax Error 'Archive' tag cannot be used more than once on a page")
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
    
    Liquid::Template.register_tag('archive', Archive)
    
end 

