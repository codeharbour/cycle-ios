require 'cgi'
require 'find'
#if RUBY_VERSION < "1.9"
    require 'uri'
#end


module Liquid

  module StandardFilters

def html_encode(input)
    CGI.escapeHTML(input) rescue input
end

def uri_encode(input)
    CGI.escape(input) rescue input
end

def uri_decode(input)
    CGI.unescape(input) rescue input
end

def uri_escape(input)
    #if RUBY_VERSION < "1.9"
       URI.escape(input) rescue input
       #else
       #   CGI.escape(input) rescue input
       #end
end

def uri_unescape(input)
    #if RUBY_VERSION < "1.9"
        URI.unescape(input) rescue input
        #else
        # CGI.unescape(input) rescue input
        #end
    
end

def asset_url(input)
    if input.nil? then return end
    
    file_system = Liquid::Template.file_system
    
    # Extract asset name from HAML string.
    file_name = input.clone#{}"#{input.delete(' ')[/^%[a|img|link|script].*?[src|href]=.*?"(.*?)"/i,1]}"
    
    #in case there is any path on this before the filename
    rest_of_path = File.dirname(file_name)
    
    name = File.basename(file_name, ".*")
    ext = File.extname(file_name)
    asset_name = name + ext
    
    if ext.empty? then
        return input
    end
    
    if(rest_of_path != "." || rest_of_path == "")
        asset_name = rest_of_path+ "/" + name + ext
    end
    
    # Declare an array to hold file paths.
    file_paths = []
    
    # Find files in the project path that match the asset name.
    Find.find(file_system.index_path) do |path|
        #base holds the actual filenae
        dir, base = File.split(path)
        
        test_ignore = path.sub! file_system.index_path, ''
        
        # Store any matches in our array.
        next if path.downcase.include? '/converted-html/'
        next if path.downcase.include? '/collections/'
        next if file_system.ignores.any? do |aa|
            test_ignore.start_with? '/' + aa
        end
        
        next if path.downcase.include? '/.'
        next if path.downcase.include? '/..'
        next if !path.include? rest_of_path #to ensure if there is a path that it matches as was finding images/teams/image with path of images/team/image
        next if !base.start_with? "#{name}"
        next if !base.end_with? "#{ext}"
        file_paths << path if base =~ /#{name}(.*)#{ext}/
    end
    
    # Define string for file path
    file_path = ""
    
    
    # If a match has been found.
    if file_paths.first
        
        #file_path = file_paths.find { |e| /#{name}#{ext}/ =~ e }
        file_path = file_paths.find { |e| /#{asset_name}/ =~ e }
        debugg = file_system.debug == "true"
        
        if !debugg
            #if already specifying min then don't add min again
            if !file_path
                return input
                elsif file_path.include? '.min.css'
                file_path = file_paths.find { |e| /#{name}#{ext}/ =~ e }
                
                elsif file_path.include? '.css'
                #store a temp copy in case can't find a min version
                temp_file_path = file_path.clone
                
                file_path = file_paths.find { |e| /#{name}.min#{ext}/ =~ e }
                
                if !file_path
                    file_path = temp_file_path
                end
                
                else
                
            end
            #if already specifying min then don't add min again
            if !file_path
                return input
                elsif file_path.include? '.min.js'
                file_path = file_paths.find { |e| /#{name}#{ext}/ =~ e }
                elsif file_path.include? '.js'
                #store a temp copy in case can't find a min version
                temp_file_path = file_path.clone
                
                file_path = file_paths.find { |e| /#{name}.min#{ext}/ =~ e }
                
                if !file_path
                    file_path = temp_file_path
                end
            end
            
        end
        
        if file_path.nil? then
            return input
        end
        
        # Replace the asset name with the path and render the HAML.
        return input.gsub(/#{asset_name}/, file_path.gsub(file_system.index_path,''))
        
        else
        # If not output an asset not found error to the rendered page.
        return  input
    end
    return input
    #return "[a]%s[/a]" % [input]
end

def stylesheet_tag(input)
    if input.nil? then return end
    
    #input = input.reverse.chomp('/').reverse
    return "<link href=\"%s\" rel=\"stylesheet\" type=\"text/css\" media=\"all\"/>" % input
end

def script_tag(input)
    if input.nil? then return end
    
    #input = input.reverse.chomp('/').reverse
    return "<script src=\"%s\"></script>" % input
end

def image_tag(input, alt = "")
    if input.nil? then return end
    
    return "<img src=\"%s\" alt=\"%s\" />" % [input,alt]
end

def slugify(input)
    if input.nil? then return end
    if RUBY_VERSION < "1.9"
        $KCODE = 'u'
    end
    input = input.downcase
    input = I18n.transliterate(input)
    input = input.gsub(/[^a-z0-9\s-]_/,"")
    input = input.gsub(/\s+/," ").chomp(" ")
    input = input.match(%r{^(.{0,45})})[1]
    input = input.gsub(/\s/,"-")
    
    return input.to_s
end

def lorem_ipsum(input,tag="")
    
    #===== words
    words =%{Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Integer in
        mi a mauris ornare sagittis. Suspendisse potenti. Suspendisse dapibus
        dignissim dolor. Nam sapien tellus, tempus et, tempus ac, tincidunt
        in, arcu. Duis dictum. Proin magna nulla, pellentesque non, commodo
        et, iaculis sit amet, mi. Mauris condimentum massa ut metus. Donec
        viverra, sapien mattis rutrum tristique, lacus eros semper tellus, et
        molestie nisi sapien eu massa. Vestibulum ante ipsum primis in
        faucibus orci luctus et ultrices posuere cubilia Curae; Fusce erat
        tortor, mollis ut, accumsan ut, lacinia gravida, libero. Curabitur
        massa felis, accumsan feugiat, convallis sit amet, porta vel, neque.
        Duis et ligula non elit ultricies rutrum. Suspendisse tempor.
        Quisque posuere malesuada velit. Sed pellentesque mi a purus. Integer
        imperdiet, orci a eleifend mollis, velit nulla iaculis arcu, eu rutrum
        magna quam sed elit. Nullam egestas. Integer interdum purus nec
        mauris. Vestibulum ac mi in nunc suscipit dapibus. Duis consectetuer,
        ipsum et pharetra sollicitudin, metus turpis facilisis magna, vitae
        dictum ligula nulla nec mi. Nunc ante urna, gravida sit amet, congue
        et, accumsan vitae, magna. Praesent luctus. Nullam in velit. Praesent
        est. Curabitur turpis.
        Class aptent taciti sociosqu ad litora torquent per conubia nostra,
        per inceptos hymenaeos. Cras consectetuer, nibh in lacinia ornare,
        turpis sem tempor massa, sagittis feugiat mauris nibh non tellus.
        Phasellus mi. Fusce enim. Mauris ultrices, turpis eu adipiscing
        viverra, justo libero ullamcorper massa, id ultrices velit est quis
        tortor. Quisque condimentum, lacus volutpat nonummy accumsan, est nunc
        imperdiet magna, vulputate aliquet nisi risus at est. Aliquam
        imperdiet gravida tortor. Praesent interdum accumsan ante. Vivamus est
        ligula, consequat sed, pulvinar eu, consequat vitae, eros. Nulla elit
        nunc, congue eget, scelerisque a, tempor ac, nisi. Morbi facilisis.
        Pellentesque habitant morbi tristique senectus et netus et malesuada
        fames ac turpis egestas. In hac habitasse platea dictumst. Suspendisse
        vel lorem ut ligula tempor consequat. Quisque consectetuer nisl eget
        elit.
        Proin quis mauris ac orci accumsan suscipit. Sed ipsum. Sed vel libero
        nec elit feugiat blandit. Vestibulum purus nulla, accumsan et,
        volutpat at, pellentesque vel, urna. Suspendisse nonummy. Aliquam
        pulvinar libero. Donec vulputate, orci ornare bibendum condimentum,
        lorem elit dignissim sapien, ut aliquam nibh augue in turpis.
        Phasellus ac eros. Praesent luctus, lorem a mollis lacinia, leo turpis
        commodo sem, in lacinia mi quam et quam. Curabitur a libero vel tellus
        mattis imperdiet. In congue, neque ut scelerisque bibendum, libero
        lacus ullamcorper sapien, quis aliquet massa velit vel orci. Fusce in
        nulla quis est cursus gravida. In nibh. Lorem ipsum dolor sit amet,
        consectetuer adipiscing elit. Integer fermentum pretium massa. Morbi
        feugiat iaculis nunc.
        Aenean aliquam pretium orci. Cum sociis natoque penatibus et magnis
        dis parturient montes, nascetur ridiculus mus. Vivamus quis tellus vel
        quam varius bibendum. Fusce est metus, feugiat at, porttitor et,
        cursus quis, pede. Nam ut augue. Nulla posuere. Phasellus at dolor a
        enim cursus vestibulum. Duis id nisi. Duis semper tellus ac nulla.
        Vestibulum scelerisque lobortis dolor. Aenean a felis. Aliquam erat
        volutpat. Donec a magna vitae pede sagittis lacinia. Cras vestibulum
        diam ut arcu. Mauris a nunc. Duis sollicitudin erat sit amet turpis.
        Proin at libero eu diam lobortis fermentum. Nunc lorem turpis,
        imperdiet id, gravida eget, aliquet sed, purus. Ut vehicula laoreet
        ante.
        Mauris eu nunc. Sed sit amet elit nec ipsum aliquam egestas. Donec non
        nibh. Cras sodales pretium massa. Praesent hendrerit est et risus.
        Vivamus eget pede. Curabitur tristique scelerisque dui. Nullam
        ullamcorper. Vivamus venenatis velit eget enim. Nunc eu nunc eget
        felis malesuada fermentum. Quisque magna. Mauris ligula felis, luctus
        a, aliquet nec, vulputate eget, magna. Quisque placerat diam sed arcu.
        Praesent sollicitudin. Aliquam non sapien. Quisque id augue. Class
        aptent taciti sociosqu ad litora torquent per conubia nostra, per
        inceptos hymenaeos. Etiam lacus lectus, mollis quis, mattis nec,
        commodo facilisis, nibh. Sed sodales sapien ac ante. Duis eget lectus
        in nibh lacinia auctor.
        Fusce interdum lectus non dui. Integer accumsan. Quisque quam.
        Curabitur scelerisque imperdiet nisl. Suspendisse potenti. Nam massa
        leo, iaculis sed, accumsan id, ultrices nec, velit. Suspendisse
        potenti. Mauris bibendum, turpis ac viverra sollicitudin, metus massa
        interdum orci, non imperdiet orci ante at ipsum. Etiam eget magna.
        Mauris at tortor eu lectus tempor tincidunt. Phasellus justo purus,
        pharetra ut, ultricies nec, consequat vel, nisi. Fusce vitae velit at
        libero sollicitudin sodales. Aenean mi libero, ultrices id, suscipit
        vitae, dapibus eu, metus. Aenean vestibulum nibh ac massa. Vivamus
        vestibulum libero vitae purus. In hac habitasse platea dictumst.
        Curabitur blandit nunc non arcu.
        Ut nec nibh. Morbi quis leo vel magna commodo rhoncus. Donec congue
        leo eu lacus. Pellentesque at erat id mi consequat congue. Praesent a
        nisl ut diam interdum molestie. Fusce suscipit rhoncus sem. Donec
        pretium. Aliquam molestie. Vivamus et justo at augue aliquet dapibus.
        Pellentesque felis.
        Morbi semper. In venenatis imperdiet neque. Donec auctor molestie
        augue. Nulla id arcu sit amet dui lacinia convallis. Proin tincidunt.
        Proin a ante. Nunc imperdiet augue. Nullam sit amet arcu. Quisque
        laoreet viverra felis. Lorem ipsum dolor sit amet, consectetuer
        adipiscing elit. In hac habitasse platea dictumst. Pellentesque
        habitant morbi tristique senectus et netus et malesuada fames ac
        turpis egestas. Class aptent taciti sociosqu ad litora torquent per
        conubia nostra, per inceptos hymenaeos. Nullam nibh sapien, volutpat
        ut, placerat quis, ornare at, lorem. Class aptent taciti sociosqu ad
        litora torquent per conubia nostra, per inceptos hymenaeos.
        Morbi dictum massa id libero. Ut neque. Phasellus tincidunt, nibh ut
        tincidunt lacinia, lacus nulla aliquam mi, a interdum dui augue non
        pede. Duis nunc magna, vulputate a, porta at, tincidunt a, nulla.
        Praesent facilisis. Suspendisse sodales feugiat purus. Cras et justo a
        mauris mollis imperdiet. Morbi erat mi, ultrices eget, aliquam
        elementum, iaculis id, velit. In scelerisque enim sit amet turpis. Sed
        aliquam, odio nonummy ullamcorper mollis, lacus nibh tempor dolor, sit
        amet varius sem neque ac dui. Nunc et est eu massa eleifend mollis.
        Mauris aliquet orci quis tellus. Ut mattis.
        Praesent mollis consectetuer quam. Nulla nulla. Nunc accumsan, nunc
        sit amet scelerisque porttitor, nibh pede lacinia justo, tristique
        mattis purus eros non velit. Aenean sagittis commodo erat. Aliquam id
        lacus. Morbi vulputate vestibulum elit.}
    
    words.gsub!(/\n/,' ')
    words.gsub!(/\./,' ')
    words.gsub!(/\,/,' ')
    words.gsub!(/  */,' ')
    words.strip!
    words.downcase!
    words = words.split(/ /)
    
    
    #===== lorem
    lorem = ""
    temp = ""
    #0.upto(word_count) {|n| lorem << words[rand(words.length)]}
    
    paragraphs = input
    pp=0
    while pp < paragraphs
        #===== total
        twn = 0
        twc = 50
        while twn < twc
            
            #===== paragraph
            pwn = 0
            pwc = rand(100)+200
            while pwn < pwc and twn < twc do
                
                #===== sentence
                swn = 0
                swc = rand(10)+3
                while swn < swc and pwn < pwc and twn < twc do
                    
                    word = words[rand(words.length)]
                    if swn == 0
                        temp << "#{word.capitalize} "
                        else
                        temp << "#{word} "
                    end
                    
                    twn +=1
                    pwn +=1
                    swn +=1
                    
                end
                temp << ". "
                
                end
                temp << "\n\n"
                
            end
            if(tag.length > 0)
                if pp == 0
                    first_word = temp.split[0...1].join(' ')
                    
                    first_word_downcase = first_word.downcase
                    lorem_first_word = "Lorem ipsum " + first_word_downcase
                    lorem = "<"+tag+">"+temp.sub(first_word, lorem_first_word)+"</"+tag+">"
                    else
                    lorem += "<"+tag+">"+temp+"</"+tag+">"
                end
                else
                if pp == 0
                    first_word = temp.split[0...1].join(' ')
                    first_word_downcase = first_word.downcase
                    lorem_first_word = "Lorem ipsum " + first_word_downcase
                    lorem = temp.sub(first_word, lorem_first_word)
                    else
                    lorem += temp
                end
                
            end
            temp = ""
            pp = pp + 1
            end
            lorem = lorem.gsub!(/ \./,'.')
            
            
            return lorem
            
        end
        
        
        def placeholder(input,colour1="",colour2="")
        
        if input.length == 0
            input = "200"
        end
        
        if colour1.length == 0 then
            return "/_mixture_placeholder/%s" % input
        end
        if colour2.length == 0  then
            return "/_mixture_placeholder/%s/%s" % [input, colour1]
        end
        
        return "/_mixture_placeholder/%s/%s/%s" % [input, colour1,colour2]
    end
    
    def placeholder_html(input,colour1="",colour2="")
        
        if input.length == 0
            input = "200"
        end
        
        if colour1.length == 0 then
            return "http://imgsrc.me/%s" % input
        end
        if colour2.length == 0  then
            return "http://imgsrc.me/%s/%s" % [input, colour1]
        end
        
        return "http://imgsrc.me/%s/%s/%s" % [input, colour1,colour2]
    end
    
    def navigation(data, url = "", wrap = "", childwrap = "", style = "", home = "")
        
        if url.empty?
            url = "/"
        end
        
        if home.empty?
            home = "home"
        end
        
        if wrap.empty?
            wrap = ""
        end
        
        if childwrap.empty?
            childwrap = ""
        end
        
        if style.empty?
            style = "selected"
        end
        
        
        wrapOpen = ""
        wrapClose = ""
        
        if(wrap != "")
            wrapOpen = "<#{wrap}>"
            wrapClose = "</#{wrap}>"
        end
        
        return "#{wrapOpen}"+ nav_recurse(data,url,wrap,childwrap,style,home) +"#{wrapClose}"
        
    end
    
    def nav_recurse(data, url, wrap, childwrap, style, home)
        
        file_system = Liquid::Template.file_system
        default_template = file_system.default_template
        
        default_template = default_template.downcase
        return_value = ""
        data.each do |item|
            u = ""
            if item["url"] == "/#{default_template}"
                u = "/"
                else
                u = item["url"]
            end
            n = ""
            if item["url"] == "/#{default_template}"
                n = home
                else
                n = item["name"]
            end
            selected = ""
            if item["url"] == "/#{url}"
                selected = " class=\"#{style}\""
            end
            
            myurl = ""
            if url == default_template
                myurl = "/"
                else
                myurl = "/#{url}"
            end
            
            
            if myurl == "/" && u == "/"
                selected = " class=\"#{style}\""
                elsif myurl.start_with?(u) and u != "/"
                selected = " class=\"#{style}\""
            end
            
            wrapOpen = ""
            wrapClose = ""
            if !wrap.empty?
                wrapOpen = "<#{wrap}>"
                wrapClose = "</#{wrap}>"
            end
            
            childwrapOpen = ""
            childwrapClose = ""
            
            if !childwrap.empty?
                childwrapOpen = "<#{childwrap}#{selected}>"
                childwrapClose = "</#{childwrap}>"
            end
            
            folder = item["directory"]
            
            if (folder)
                if item["children"] != nil
                    return_value = return_value + "#{childwrapOpen}<span#{selected}>#{n}</span>#{wrapOpen}"+nav_recurse(item["children"],url,wrap,childwrap,style,home)+"#{wrapClose}#{childwrapClose}"
                    else
                    
                    return_value = return_value + "#{childwrapOpen}<span#{selected}>#{n}</span>#{childwrapClose}"
                end
                else
                if item["children"] != nil
                    return_value = return_value + "#{childwrapOpen}<a href=\"#{u}\"#{selected}>#{n}</a>#{wrapOpen}"+nav_recurse(item["children"],url,wrap,childwrap,style,home)+"#{wrapClose}#{childwrapClose}"
                    else
                    return_value = return_value + "#{childwrapOpen}<a href=\"#{u}\"#{selected}>#{n}</a>#{childwrapClose}"
                end
            end
            
        end
        
        return_value
    end


    # Return the size of an array or of an string
    def size(input)

      input.respond_to?(:size) ? input.size : 0
    end

    # convert a input string to DOWNCASE
    def downcase(input)
      input.to_s.downcase
    end

    # convert a input string to UPCASE
    def upcase(input)
      input.to_s.upcase
    end

    # capitalize words in the input centence
    def capitalize(input)
      input.to_s.capitalize
    end
    
    def camelize(input)
        if input.nil? then return end
        
        if RUBY_VERSION < "1.9"
            $KCODE = 'u'
        end
        input = input.downcase
        input = input.gsub(/[^a-z0-9\s-]/,"")
        input = input.gsub(/\s+/," ").chomp(" ")
        input = input.gsub(/\s/,"_")
        
        temp = input.split(/[_-]/).map {|w| w.capitalize}.join(' ')
        
        #now go back through and replace
        input.chars.to_a.each_with_index do |element,index|
            
            if element == '-'
                temp[index] = '-'
                
                elsif  element == '_'
                temp[index] = '_'
                
            end
        end
        
        temp = temp.split('_').join('')
        temp = temp.split('-').join(' ')
    end
    
      def camelcase(input)
          if input.nil? then return end
          
          if RUBY_VERSION < "1.9"
              $KCODE = 'u'
            end
          input = input.downcase
          input = input.gsub(/[^a-z0-9\s-]/,"")
          input = input.gsub(/\s+/," ").chomp(" ")
          input = input.gsub(/\s/,"_")
          
          temp = input.split(/[_-]/).map {|w| w.capitalize}.join(' ')
          
          #now go back through and replace
          input.chars.to_a.each_with_index do |element,index|
              
              if element == '-'
                  temp[index] = '-'
                  
                  elsif  element == '_'
                  temp[index] = '_'
                  
              end
          end
          
          temp = temp.split('_').join('')
          temp = temp.split('-').join(' ')
      end

    def escape(input)
      CGI.escapeHTML(input) rescue input
    end

    def escape_once(input)
      ActionView::Helpers::TagHelper.escape_once(input)
    rescue NameError
      input
    end

    alias_method :h, :escape

    # Truncate a string down to x characters
    def truncate(input, length = 50, truncate_string = "...")
      
        
        if input.nil? then return end
      l = length.to_i - truncate_string.length
      l = 0 if l < 0
        #mixture
        a=0
      test = input.length > length.to_i ? input.chars.take_while{|c| (a += c.bytes.to_a.length) <= length }.join + truncate_string : input
        #puts test
        return test
    end

    def truncatewords(input, words = 15, truncate_string = "...")
      if input.nil? then return end
      wordlist = input.to_s.split
      l = words.to_i - 1
      l = 0 if l < 0
      wordlist.length > l ? wordlist[0..l].join(" ") + truncate_string : input
    end

    # Split input string into an array of substrings separated by given pattern.
    #
    # Example:
    #   <div class="summary">{{ post | split '//' | first }}</div>
    #
    def split(input, pattern)
      input.split(pattern)
    end

    def strip_html(input)
      input.to_s.gsub(/<script.*?<\/script>/, '').gsub(/<!--.*?-->/, '').gsub(/<.*?>/, '')
    end

    # Remove all newlines from the string
    def strip_newlines(input)
      input.to_s.gsub(/\n/, '')
    end


    # Join elements of the array with certain character between them
    def join(input, glue = ' ')
      [input].flatten.join(glue)
    end

    # Sort elements of the array
    # provide optional property with which to sort an array of hashes or drops
    def sort(input, property = nil)
      ary = [input].flatten
      if property.nil?
        ary.sort
      elsif ary.first.respond_to?('[]') and !ary.first[property].nil?
        ary.sort {|a,b| a[property] <=> b[property] }
      elsif ary.first.respond_to?(property)
        ary.sort {|a,b| a.send(property) <=> b.send(property) }
      end
    end

    # map/collect on a given property
    def map(input, property)
      ary = [input].flatten
      if ary.first.respond_to?('[]') and !ary.first[property].nil?
        ary.map {|e| e[property] }
      elsif ary.first.respond_to?(property)
        ary.map {|e| e.send(property) }
      end
    end

    # Replace occurrences of a string with another
    def replace(input, string, replacement = '')
      input.to_s.gsub(string, replacement)
    end

    # Replace the first occurrences of a string with another
    def replace_first(input, string, replacement = '')
      input.to_s.sub(string, replacement)
    end

    # remove a substring
    def remove(input, string)
      input.to_s.gsub(string, '')
    end

    # remove the first occurrences of a substring
    def remove_first(input, string)
      input.to_s.sub(string, '')
    end

    # add one string to another
    def append(input, string)
      input.to_s + string.to_s
    end

    # prepend a string to another
    def prepend(input, string)
      string.to_s + input.to_s
    end

    # Add <br /> tags in front of all newlines in input string
    def newline_to_br(input)
      input.to_s.gsub(/\n/, "<br />\n")
    end

# Reformat a date
#
#   %a - The abbreviated weekday name (``Sun'')
#   %A - The  full  weekday  name (``Sunday'')
#   %b - The abbreviated month name (``Jan'')
#   %B - The  full  month  name (``January'')
#   %c - The preferred local date and time representation
#   %d - Day of the month (01..31)
#   %H - Hour of the day, 24-hour clock (00..23)
#   %I - Hour of the day, 12-hour clock (01..12)
#   %j - Day of the year (001..366)
#   %m - Month of the year (01..12)
#   %M - Minute of the hour (00..59)
#   %p - Meridian indicator (``AM''  or  ``PM'')
#   %S - Second of the minute (00..60)
#   %U - Week  number  of the current year,
#           starting with the first Sunday as the first
#           day of the first week (00..53)
#   %W - Week  number  of the current year,
#           starting with the first Monday as the first
#           day of the first week (00..53)
#   %w - Day of the week (Sunday is 0, 0..6)
#   %x - Preferred representation for the date alone, no time
#   %X - Preferred representation for the time alone, no date
#   %y - Year without a century (00..99)
#   %Y - Year with century
#   %Z - Time zone name
#   %% - Literal ``%'' character
def date(input, format)
    
    if format.to_s.empty?
        return input.to_s
    end
    
    if ((input.is_a?(String) && !/^\d+$/.match(input.to_s).nil?) || input.is_a?(Integer)) && input.to_i > 0
        input = Time.at(input.to_i)
    end
    
    date = if input.is_a?(String)
    case input.downcase
        when 'now', 'today'
        Time.now
        else
        Time.parse(input)
    end
    else
    input
end

if date.respond_to?(:strftime)
    date.strftime(format.to_s)
    else
    input
end
rescue
input
end

    # Get the first element of the passed in array
    #
    # Example:
    #    {{ product.images | first | to_img }}
    #
    def first(array)
      array.first if array.respond_to?(:first)
    end

    # Get the last element of the passed in array
    #
    # Example:
    #    {{ product.images | last | to_img }}
    #
    def last(array)
      array.last if array.respond_to?(:last)
    end

    # addition
    def plus(input, operand)
      to_number(input) + to_number(operand)
    end

    # subtraction
    def minus(input, operand)
      to_number(input) - to_number(operand)
    end

    # multiplication
    def times(input, operand)
      to_number(input) * to_number(operand)
    end

    # division
    def divided_by(input, operand)
      to_number(input) / to_number(operand)
    end

    def modulo(input, operand)
      to_number(input) % to_number(operand)
    end

    private

      def to_number(obj)
        case obj
        when Numeric
          obj
        when String
          (obj.strip =~ /^\d+\.\d+$/) ? obj.to_f : obj.to_i
        else
          0
        end
      end

  end

  Template.register_filter(StandardFilters)
end
