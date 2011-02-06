require_relative '../lib/ruby2D'
include Ruby2D

Cache.add_location 'Other/'
Window.name = 'Empty'
Window.resize 256, 256
Window.run do
  loop { Graphics.update }
end
