class HamlRendererRegions < HamlRenderer
  
	def initialize
		@regions_hash={}
	end

	def content_for(region, &blk)
		@regions_hash[region] = capture_haml(&blk)
	end

	def [](region)
		@regions_hash[region]
	end

end