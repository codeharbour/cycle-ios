require 'liquid'

module LiquidInheritance
  autoload :Layout, 'tags/layout'
  autoload :Block, 'tags/block'
end

Liquid::Template.register_tag(:layout, LiquidInheritance::Layout)
Liquid::Template.register_tag(:block, LiquidInheritance::Block)