require 'test/unit'
require 'collections_handler'

class TestCollectionsHandler < Test::Unit::TestCase
  
  def setup
  	puts "Setting up the tests on CollectionsHandler"

  end

#begin
  def test_run_processed
	
	coll_hand = CollectionsHandler.new
  	project_root = "/Users/petenelson/Desktop/afafa"
    templates = "/Users/petenelson/Desktop/afafa/templates"
    nodebin = "/Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/nodebin/node-v0.10.10-darwin-x64/bin/node" 
    nodeyaml = "/Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/nodebin/mixture-yaml.js"
    
    puts coll_hand.run_processed(nodebin,nodeyaml,project_root,templates, false)
  	
  end
#end
=begin
  def test_collection_load
    
  	coll_hand = CollectionsHandler.new
  	loaded_collection = coll_hand.load_collection

  	#all four files were processed
    assert_equal(4, loaded_collection.length)
    #if published is null then gets set to false
    assert_equal(false, loaded_collection["/2013-04-25"]["published"])
    #if published is false then is indeed false
    assert_equal(false, loaded_collection["/2013-04-28"]["published"])

    
    #check items with null date get filesystem created date
    assert_equal(Time.utc(2013,"Apr",28,19,14,52), loaded_collection["/2013-04-26"]["mixture_date"])

  end

  def test_build_index
  	coll_hand = CollectionsHandler.new
  	loaded_collection = coll_hand.load_collection

  	coll_hand.build_index(loaded_collection)

  	assert_equal(true,true)
  end

  def test_order_by

  	coll_hand = CollectionsHandler.new
  	loaded_collection = coll_hand.load_collection
	
  	sorted_collection = coll_hand.order_by(loaded_collection,"mixture_date","asc")

  	puts sorted_collection.inspect


  end

  def test_run_on_project
	
	coll_hand = CollectionsHandler.new
  	project_root = "/Users/petenelson/Desktop/CollectionsProject - Demo"
  	save_path = "/Users/petenelson/Documents/dev/ruby/mixture_collections/indexing.json"
  	collections_paths = ["/templates/blog/","/templates/portfolio/"]

  	coll_hand.run_on_project(project_root,collections_paths,save_path)

  	assert_equal(true,true)
  		
  end
=end
=begin
  def test_run_basic_liquid_page

#/usr/bin/ruby -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/json_pure-1.8.1/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/liquid-2.4.1/lib -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/kramdown-1.2.0/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/haml-4.0.5/lib -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/tilt-1.3.7/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/custom-liquid-inheritance/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/i18n-0.6.9/lib/ -I . test_collections_handler.rb

  	basic_template = <<-eos 
  		{% collection "blog" by 2 query 'month={{ mixture.route.month }}&year={{ mixture.route.year }}' order desc %}
		<ul class="blog-items">{% include "blog/article" with collection.items %}</ul>
		<!-- Example paging based on the collection data -->
		<div class="paging">
			{% if collection.previous %}
				<a href="/blog/page-{{ collection.current_page | minus:1 }}">Previous</a>
			{% endif %}
			<em>Showing items {{ collection.current_offset | plus: 1 }}-{% if collection.next %}{{ collection.current_offset | plus: collection.page_size }}{% else %}{{ collection.size }}{% endif %} of {{ collection.size }}</em>
			{% if collection.next %}
				<a href="/blog/page-{{ collection.current_page | plus:1 }}">Next</a>
			{% endif %}
		</div>
	{% endcollection %}
	<!-- Display a group for blog items by date (which will group by month and year) -->
	{% grouped 'blog' by 'date' %}
		<h3>Archives</h3>
		{% include "blog/date" with grouped.items %}
	{% endgrouped %}
	eos

basic_template = <<-eos 
  		<h1>Archive</h1>
	{% archive "blog" %}
		{% for item in archive.items %}
			<h3>{{ item.year }}</h3>
			<ul class="archive">
			{% for post in item.children %}
				<li><a href="{{ post.slug }}">{{ post.title }}</a></li>
			{% endfor %}
			</ul>
		{% endfor %}
	{% endarchive %}
	eos

	coll_hand = CollectionsHandler.new

	#puts coll_hand.run_liquid_page(basic_template)

  end

=end

def test_run_basic_liquid_page

#       /usr/bin/ruby -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/json_pure-1.8.1/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/liquid-2.4.1/lib -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/kramdown-1.2.0/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/haml-4.0.5/lib -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/tilt-1.3.7/lib/ -I /Users/petenelson/Documents/dev/macos/BuildPushMac/mixture_mac/gems/RbYAML-0.2.0/lib/ test_collections_handler.rb



    basic_template = <<-eos 
      {% layout "layout" %}
      {{ "screen.css" | asset_url | stylesheet_tag }}
      {{ "pete.css" | asset_url | stylesheet_tag }}
        {{ "jquerypete-1.8.2.min.js" | asset_url | script_tag }}
        <!-- TODO: DELETE ME -->
        {{ "app.min" | asset_url | stylesheet_tag }}
        {{ "/images/team/test.png" | asset_url }}
         {{ "pete.js" | asset_url | script_tag }}
{{ "testpete.js" | asset_url | script_tag }}
 {% block content %}
<b>THIS IS A ATEST</b>
Hello {{ 'now' | date: "%Y %h" }}
{{ name }} NAME
{% endblock %}

 {% assign starturl = "/article/" %}
  {% assign peteurl = "liquid-example" %}
  {% block sub_nav %}
                    hello
                    {% endblock %}
{% block sub_nav_secondary %}secondary{% endblock %}
 
  eos
  coll_hand = CollectionsHandler.new
#
##
#SET  up the paths!!!!!!!!! in collections handler file not here!!!
  
  puts coll_hand.run_liquid_page(basic_template)
end










end