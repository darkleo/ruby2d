$:.insert 0, '../lib/'
require 'ruby2d'

Cache.add_location 'Other/'
Window.name = 'Empty'
Window.resize 128, 128
Window.run {
  Graphics.framerate = 1.0/0
  #~ s = Sprite.new
  #~ s.texture = Texture.new 'Star.bmp'
  #~ s.ox = s.oy = s.x = s.y = 64
  i, m, t = 0, 20.0, Time.now
  loop {
    Graphics.update
    #~ s.angle += 1
    i += 1
    if i == m
      t2 = Time.now
      p m/(t2-t)
      i, t = 0, t2
    end
  }
}