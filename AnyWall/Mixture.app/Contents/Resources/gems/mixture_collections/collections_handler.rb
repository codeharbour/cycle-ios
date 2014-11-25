class CollectionsHandler
    
    require 'yaml'
    require 'time'
    require 'json'
    require 'liquid_inheritance'
    require 'liquid'
    #require 'mixturefilesystem'
    #require 'mixturefilters'
    require 'collection'
    require 'pathname'
    require 'grouped'
    require 'kramdown'
    require 'haml'
    require 'item'
    require 'archive'
    require 'date'
    require 'i18n'
    
    I18n.enforce_available_locales = false
    
    def slugify(input)
        
        if input.nil? then return end
        
        if RUBY_VERSION < "1.9"
            $KCODE = 'u'
            else
            
        end
        
        if RUBY_VERSION < "1.9"
            
            else
            input = input.force_encoding("UTF-8")
        end
        
        input = input.downcase
        
        input = input.gsub(/\s+/," ").chomp(" ")
        
        input = input.gsub(/\s/,"-")
        I18n.enforce_available_locales = false
        input = I18n.transliterate(input)
        input = input.gsub(/[^\/\w-]/, '')
        
        return input.to_s
    end
    
    def string_to_time time_, format_
        time = Date._strptime(time_, format_)
        return Time.local(time[:year], time[:mon], time[:mday], time[:hour], time[:min], time[:sec], time[:sec_fraction], time[:zone])
    end
    
    def load_collection_processed (nodebin,nodeyaml,project_root,full_collection_path,processed_last,processed_copy,templates,debug,ignore_date = false, ignores = 'ignore')
        
        collection = Hash.new
        
        collection_path = full_collection_path.dup
        collection_from_root = collection_path.dup
        
        errorList = Hash.new
        successList = Hash.new
        uniqueSlugs = Hash.new
        
        #puts processed_copy.inspect
        processed_copy.each do |ff|
            #p@uts "hello "+uniqueSlugs[ff[1]["FilePath"]]
            #if uniqueSlugs[ff[1]["FilePath"]] != nil
            uniqueSlugs[ff[1]["Url"]] =ff[1]["FilePath"]
            #end
        end
        
        #uniqueSlugs.each do |ss|
        #puts ss.inspect
        #end
        
        if collection_from_root.include?(project_root)
            
            collection_from_root [project_root] = ""
        end
        
        accepted_formats = [".md", ".haml",".liquid"]
        
        Dir.foreach(collection_path) do |item|
            next if item == '.' or item == '..' or item.start_with?(".") or !accepted_formats.include? File.extname(item)
            
            full_path = File.join(collection_path,item)
            
            #take out the project root
            file_url_key = File.join(collection_from_root,item)
            
            #ignore_date
            if processed_copy[file_url_key] == nil or processed_last == nil or processed_last < File.mtime(full_path).utc
                
                prefix = collection_from_root.dup
                prefix.slice! "/collections/"
                fileinfo = Hash.new
                
                
                
                #file = File.open(full_path)
                #contents = file.read
                
                #here I need to get the header from the document
                #yaml_header_array = contents.split("---")
                #yaml_header = ""
                #if yaml_header_array.length >= 2
                # yaml_header = yaml_header_array[1]
                #else
                # errorList[full_path] = "Failed to load post data, please check the post is valid"
                # next
                #end
                #puts yaml_header.inspect
                
                #begin
                
                # meta = RbYAML.load(yaml_header)
                
                #rescue
                # errorList[full_path] = "Failed to load post data, please check the post is valid"
                # next
                #end
                #body = contents.gsub(/---(.|\n)*---/, '')
                #file.close
                begin
                    #in future may need to watch for spaces in  path to node
                    comm = nodebin +" "+nodeyaml +" '"+ full_path+"'"
                    #comm = ("\"#{nodebin}\" \"#{nodeyaml}\" \"#{full_path}\"")
                    
                    io = IO.popen comm
                    
                    metastring = io.read
                    #puts metastring
                    io.close
                    if RUBY_VERSION >= "1.9"
                        #if contents.is_a? String
                        metastring = metastring.force_encoding("UTF-8")
                        #end
                    end
                    meta_hash = JSON.parse(metastring)
                    
                    #puts meta_hash
                    #should only be one keyvalue
                    meta = meta_hash[0]
                    body = meta_hash[1]
                    
                    
                    
                    
                    #meta = RbYAML.load(yaml_header)
                    
                    
                    rescue => error
                    errorList[full_path] = "Failed to load post data, please check the post is valid"#+error.backtrace.to_s
                    next
                end
                
                post_date = nil
                if meta["date"] == nil
                    #if they have a date in the meta it should override the file date
                    raw_creation_time = `mdls -name kMDItemContentCreationDate -raw "#{full_path}"`
                    post_date = Time.parse(raw_creation_time).iso8601
                    else
                    begin
                        #puts meta["date"].inspect
                        #test_date = Date.strptime(meta["date"],'%Y-%m-%d %H:%M')
                        #puts meta["date"]
                        t = Time.parse(meta["date"]+ " UTC")
                        
                        
                        #parsed_date = DateTime.strptime(meta["date"],'%Y-%m-%d %H:%M').utc.to_time
                        #puts parsed_date+" - "+file_url_key
                        post_date = t.iso8601
                        
                        
                        rescue
                        
                        errorList[full_path] = "Invalid date used - a valid date format is yyyy-MM-dd HH:mm"
                        next
                    end
                end
                
                meta["date"] = post_date
                #slug
                file_name = item.chomp(File.extname(item))
                
                url = if meta["slug"]
                #puts meta["slug"] + " " + file_name
                metaslug = meta["slug"]
                if metaslug.start_with?("/") and metaslug.length > 1
                    metaslug = metaslug[1, metaslug.length]
                end
                slugify("/"+ prefix +"/"+ metaslug)
                else
                slugify("/"+ prefix +"/"+ file_name)
            end
            
            if uniqueSlugs[url] == nil
                uniqueSlugs[url] = file_url_key
                #puts "adding in "+url +" "+file_url_key
                elsif uniqueSlugs[url] == file_url_key
                #do nothing
                else
                #puts "already in there"+url
                url_taken = url.clone;
                errorList[full_path] = "The URL for this post is already taken by '#{url_taken}' please update one of the posts."
                next
                
            end
            
            fileinfo["Prefix"] = prefix
            fileinfo["Url"] = url
            fileinfo["Date"] = post_date
            fileinfo["FilePath"] = file_url_key
            
            #do not remove - required for publish to server!
            fileinfo["Published"] = meta["published"] == nil ? false : meta["published"]
            
            meta["slug"] = url
            
            #meta["mixture_full_path"] = full_path
            
            #meta["mixture_date"] = Time.parse(post_date).utc
            #meta["mixture_month_year"] = Time.parse(post_date).strftime("%m/%Y")
            #meta["month"] = Time.parse(post_date).strftime("%m")
            #meta["year"] = Time.parse(post_date).strftime("%Y")
            
            meta["published"] = false if meta["published"] == nil
            
=begin meta.each do |mm|
             if(mm[1].kind_of?(Array))
             #items inside are not actually an array and still need splitting by comma
             into_array = Array.new
             mm[1].each do |sub|
             puts sub.inspect
             puts "sub is array "+ sub.kind_of?(Array).to_s
             #if(sub.kind_of?(String))
             #sub.split(',').map(&:strip).each do |cat|
             #into_array.push(cat)
             #end
             end
             meta[mm[0]] = into_array
             end
             end
=end
            
            
            model = Hash.new
            model["model"] = meta.clone
            
            begin
                processed_body = parse(body,File.extname(item),model,templates,project_root,debug,ignores)
                
                successList[full_path] = "ok"
                rescue Exception => e
                errorList[full_path] = e.message
                
            end
            meta["body"] = processed_body
            fileinfo["Meta"] = meta
            collection[file_url_key] = fileinfo
            
            
        end
        
    end
    
    dataToReturn = Hash.new
    dataToReturn["collection"] = collection
    dataToReturn["errors"] = errorList
    dataToReturn["successes"] = successList
    
    return dataToReturn
end

def parse(text, ext,model,templates,root,debug, ignores)
    
    #escape raw
    #text = text.gsub("{% raw %}", "<--mix--<% raw %>--mix-->")
    #text = text.gsub("{% endraw %}", "<--mix--<% endraw %>--mix-->")
    
    Liquid::Template.file_system = Liquid::MixtureFileSystem.new(templates,root,debug,"", ignores)
    
    #Liquid::Template.register_filter(MixtureFilters)
    
    
    
    if(ext.casecmp(".md") == 0)
        
        template = Liquid::Template.parse(text)
        
        html = template.render(model)
        
        Kramdown::Document.new(html, :input => 'GFM', :auto_ids => false).to_html
        
        elsif(ext.casecmp(".haml") == 0)
        
        haml_engine = Haml::Engine.new(text)
        haml_engine.render(Object.new, model)
        
        elsif(ext.casecmp(".liquid") == 0)
        
        template = Liquid::Template.parse(text)
        template.render(model)
        
    end
end

def build_index(collection)
    
    index = Hash.new
    collection.each do |e|
        
        meta = e[1]
        
        meta.keys.each do |k|
            if k != "body" and k != "published" and k != "date"  #no need for date in the index
                if index[k] == nil
                    new_hash = Hash.new
                    
                    if(meta[k].kind_of?(Array))
                        
                        meta[k].each do |sub|
                            #items inside are not actually an array and still need splitting by comma
                            #watch out for floats here that can confuse matters
                            
                            if !sub.is_a? String
                                sub = sub.to_s
                            end
                            #sub.scan(/./).each do |cat|
                            #puts cat.to_s
                            id_array = Array.new(1,e[0])
                            new_hash[sub.to_s.downcase] = id_array
                            
                            index[k] = new_hash
                            #end
                            
                        end
                        
                        else
                        
                        id_array = Array.new(1,e[0])
                        new_hash[meta[k].to_s.downcase] = id_array
                        
                        
                        
                        
                        
                        
                        
                        index[k] = new_hash
                    end
                    
                    else
                    #the key is already in there eg category so we just want to add to it instead
                    existing_hash = index[k]
                    
                    if(meta[k].kind_of?(Array))
                        
                        
                        meta[k].each do |sub|
                            #items inside are not actually an array and still need splitting by comma
                            #watch out for floats here that can confuse matters
                            if !sub.is_a? String
                                sub = sub.to_s
                            end
                            #sub.scan(/./).each do |cat|
                            
                            
                            if existing_hash[sub.to_s.downcase] == nil
                                id_array = Array.new(1,e[0])
                                existing_hash[sub.to_s.downcase] = id_array
                                
                                index[k] = existing_hash
                                else
                                id_array = existing_hash[sub.to_s.downcase]
                                id_array.push(e[0])
                                existing_hash[sub.to_s.downcase] = id_array
                                
                                index[k] = existing_hash
                            end
                            #end
                            
                        end
                        
                        else
                        
                        if existing_hash[meta[k].to_s.downcase] == nil
                            id_array = Array.new(1,e[0])
                            existing_hash[meta[k].to_s.downcase] = id_array
                            
                            index[k] = existing_hash
                            else
                            id_array = existing_hash[meta[k].to_s.downcase]
                            id_array.push(e[0])
                            existing_hash[meta[k].to_s.downcase] = id_array
                            
                            index[k] = existing_hash
                        end
                        
                    end
                    
                    
                end
            end
            
            ###now transliterated indexes
            
            if k != "body" and k != "published" and k != "date" and k != "ticks" and k != "month" and k != "mixture_date" and k != "year" and k != "mixture_month_year" #no need for date in the index
                if index["transliterated-"+k] == nil
                    new_hash = Hash.new
                    
                    if(meta[k].kind_of?(Array))
                        
                        meta[k].each do |sub|
                            #items inside are not actually an array and still need splitting by comma
                            #watch out for floats here that can confuse matters
                            if !sub.is_a? String
                                sub = sub.to_s
                            end
                            #sub.scan(/./).each do |cat|
                            
                            id_array = Array.new(1,e[0])
                            new_hash[slugify(sub.to_s.downcase)] = id_array
                            
                            index["transliterated-"+k] = new_hash
                            #end
                            
                        end
                        
                        else
                        
                        id_array = Array.new(1,e[0])
                        new_hash[slugify(meta[k].to_s.downcase)] = id_array
                        
                        
                        
                        
                        
                        
                        
                        index["transliterated-"+k] = new_hash
                    end
                    
                    else
                    #the key is already in there eg category so we just want to add to it instead
                    existing_hash = index["transliterated-"+k]
                    
                    if(meta[k].kind_of?(Array))
                        
                        
                        meta[k].each do |sub|
                            #items inside are not actually an array and still need splitting by comma
                            #watch out for floats here that can confuse matters
                            if !sub.is_a? String
                                sub = sub.to_s
                            end
                            #sub.scan(/./).each do |cat|
                            
                            
                            if existing_hash[slugify(sub.to_s.downcase)] == nil
                                id_array = Array.new(1,e[0])
                                existing_hash[slugify(sub.to_s.downcase)] = id_array
                                
                                index["transliterated-"+k] = existing_hash
                                else
                                id_array = existing_hash[slugify(sub.to_s.downcase)]
                                id_array.push(e[0])
                                existing_hash[slugify(sub.to_s.downcase)] = id_array
                                
                                index["transliterated-"+k] = existing_hash
                            end
                            #end
                            
                        end
                        
                        else
                        
                        if existing_hash[slugify(meta[k].to_s.downcase)] == nil
                            id_array = Array.new(1,e[0])
                            existing_hash[slugify(meta[k].to_s.downcase)] = id_array
                            
                            index["transliterated-"+k] = existing_hash
                            else
                            id_array = existing_hash[slugify(meta[k].to_s.downcase)]
                            id_array.push(e[0])
                            existing_hash[slugify(meta[k].to_s.downcase)] = id_array
                            
                            index["transliterated-"+k] = existing_hash
                        end
                        
                    end
                    
                    
                end
            end
            
            
            
            ### end transliterated indexes
        end
        
    end
    
    return index
    
end

#def order_by(collection, order_by_field = "mixture_date", asc_desc = "asc")

# asc_desc == "asc" ? collection.values.sort_by { |k| k[order_by_field] }.reverse : collection.values.sort_by { |k| k[order_by_field] }

#end

#todo
#supply project root and an array of filepaths and a save path and process those and
#save in one document in the temp dir with collection path as the key
=begin
 def run_on_project(project_root, collections_paths, save_path)
 
 full_index = Hash.new
 collections_paths.each do |collection|
 project_stuff = Hash.new
 project_stuff["collection"] = load_collection(File.join(project_root,collection, "_collection/"))
 project_stuff["index"] = build_index(project_stuff["collection"])
 
 full_index[collection] = project_stuff
 end
 
 File.open(save_path,"w") do |f|
 f.write(JSON.pretty_generate(full_index))
 end
 
 end
=end
def run_processed(nodebin,nodeyaml,project_root,templates,debug, ignore_date = false, ignores = 'ignore')
    #ensure encoding
    if RUBY_VERSION < "1.9"
        else
        Encoding.default_external = Encoding::UTF_8
    end
    collections_path = File.join(project_root, "collections")
    
    if File.exist?(collections_path)
        
        
        collections_cache = File.join(collections_path, ".cache")
        
        if !File.exist?(collections_cache)
            Dir.mkdir(collections_cache)
        end
        
        processed_json = File.join(collections_cache, "processed.json")
        processed = Hash.new
        processed_last = nil
        
        errors = Hash.new
        successes = Hash.new
        returning = Hash.new
        
        
        if File.exist?(processed_json)
            processed_last = File.mtime(processed_json).utc
            
            file = File.open(processed_json)
            contents = file.read
            #$stdout.puts "ruby version "+RUBY_VERSION
            if RUBY_VERSION >= "1.9"
                #if contents.is_a? String
                contents = contents.force_encoding("UTF-8")
                #end
            end
            processed = JSON.parse(contents)
            file.close
        end
        
        
        any_changes = false
        #for using to check if any files added that are not in the hash but that have older file dates
        processed_copy = processed.clone
        
        #now find the folders that exist within this
        Dir.entries(collections_path).select {|entry|
            if File.directory?(File.join(collections_path,entry)) and !(entry =='.' || entry == '..')
                if(entry != '.cache')
                    
                    collectionAndErrors = load_collection_processed(nodebin,nodeyaml,project_root,File.join(collections_path,entry),processed_last,processed_copy,templates,debug,ignore_date,ignores)
                    collect = collectionAndErrors["collection"]
                    errors = errors.merge(collectionAndErrors["errors"])
                    
                    successes = successes.merge(collectionAndErrors["successes"])
                    if(collect.size > 0)
                        
                        any_changes = true
                        processed = processed.merge(collect)
                        
                    end
                    
                    
                end
            end
            
        }
        
        to_delete = Array.new
        #now remove any that don't exist on disk anymore
        processed.each do |ff|
            if !File.exist?(File.join(project_root,ff[0]))
                
                any_changes = true
                to_delete.push(ff[0])
            end
            
            to_delete.each { |e| processed.delete e  }
            
            
            processed.each do |kk,yy|
                if RUBY_VERSION < "1.9"
                    else
                    #prcc = yy["Meta"]
                    
                    if processed!=nil && yy != nil && yy["Meta"] != nil
                        yy["Meta"].each do |k, v|
                            
                            if v.is_a? String
                                yy["Meta"][k] = v.force_encoding("UTF-8")
                                #$stderr.puts"============" +yy["Meta"][k]
                                
                                else
                                yy["Meta"][k] = v
                            end
                            
                            
                        end
                        
                        
                        
                    end
                    #processed[kk] = prcc
                    
                    
                end
            end
        end
        
        #$stderr.puts processed.to_s.force_encoding("UTF-8")
        
        
        
        
        
        if any_changes
            
            
            
            
            #$stderr.puts processed.to_s
            
            
            File.open(processed_json,"w") do |f|
                
                
                #$stderr.puts processed_body
                if ignore_date
                    
                    f.write(JSON.pretty_generate(processed))
                    else
                    f.write(processed.to_json)
                end
            end
        end
        
        #now update the index as well - do this every save for the moment as should be fast
        indexed_json = File.join(collections_cache, "indexed.json")
        
        
        #latest_collection = ""
        all_collections = Hash.new
        processed.values.each do |coll|
            
            #coll["Meta"]["month"] = Time.iso8601(coll["Date"]).strftime("%m")
            #coll["Meta"]["year"] = Time.iso8601(coll["Date"]).strftime("%Y")
            #coll["Meta"]["date"] = Time.iso8601(coll["Date"])
            #coll["Meta"]["ticks"] = Time.iso8601(coll["Date"]).to_f
            #coll["Meta"]["mixture_month_year"] = Time.iso8601(coll["Date"]).strftime("%m/%Y")
            #coll["Meta"]["mixture_date"] = coll["Date"]
            
            nonIsoTime = Time.iso8601(coll["Date"])
            utcTime = Time.utc(nonIsoTime.year,nonIsoTime.mon,nonIsoTime.day, nonIsoTime.hour,nonIsoTime.min,nonIsoTime.sec)
            coll["Meta"]["month"] = utcTime.strftime("%m")
            coll["Meta"]["year"] = utcTime.strftime("%Y")
            coll["Meta"]["date"] = utcTime
            coll["Meta"]["ticks"] = utcTime.to_f
            coll["Meta"]["mixture_month_year"] = utcTime.strftime("%m/%Y")
            coll["Meta"]["mixture_date"] = coll["Date"]
            
            
            if all_collections[coll["Prefix"]] == nil
                new_hash = Hash.new
                new_hash[coll["Url"]] = coll["Meta"]
                all_collections[coll["Prefix"]] = new_hash
                else
                all_collections[coll["Prefix"]][coll["Url"]] = coll["Meta"]
            end
            
        end
        
        full_index = Hash.new
        
        all_collections.each do |coll|
            project_stuff = Hash.new
            project_stuff["collection"] = coll[1]
            project_stuff["index"] = build_index(project_stuff["collection"])
            
            full_index[coll[0]] = project_stuff
        end
        
        File.open(indexed_json,"w") do |f|
            f.write(JSON.pretty_generate(full_index))
        end
        
        returning["errors"] = errors
        returning["successes"] = successes
        return JSON.pretty_generate(returning)
    end
    
    return ""
    
end





def run_liquid_page(basic_template)
    
    Liquid::Template.file_system = Liquid::MixtureFileSystem.new('/Users/petenelson/Desktop/afafa/templates',"/Users/petenelson/Desktop/afafa","layout",false, "")
    #Liquid::Template.register_filter(MixtureFilters)
    @template = Liquid::Template.parse(basic_template)
    
    
    #ffile = File.open("/Users/petenelson/Desktop/Sitemap/models/_sitemap.json", "r")
    #data = ffile.read
    
    #testjson = JSON.parse(data)
    
    
    #ffile.close
    
    #@template.render( testjson )
    @template.render( 'name' => '“hello this is a test”' )
    
end

end

class Hash
    def to_utf8
        Hash[
        self.collect do |k, v|
            if (v.respond_to?(:to_utf8))
                [ k, v.to_utf8 ]
                elsif (v.is_a? String )
                [ k, v.dup.force_encoding("UTF-8") ]
                else
                [ k, v ]
            end
        end
        ]
    end
end
