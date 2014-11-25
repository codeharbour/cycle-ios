class Renderer
  
  # Renderer factory. Only HAML available at this time but
  # designed to be easily expanded to other templating langs.
  def self.factory(template_renderer)
    { :haml => HamlRenderer }[template_renderer].new
  end

end