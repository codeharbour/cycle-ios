module Haml
  class Options
    # The Mixture project variables should be available to read 
    # for use in Haml::Filters::Asseturl
    attr_reader :project_vars
  end
end