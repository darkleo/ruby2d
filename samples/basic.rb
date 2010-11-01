$:.insert 0, '../lib/'
require 'ruby2d'

Window.name = 'Light'
Window.resize 128, 128
Window.run {
  @sprite = Sprite.new
  @sprite.bitmap = Bitmap.new 'Star.bmp'
  @sprite.ox = @sprite.oy = @sprite.x = @sprite.y = 64
  i, m, t = 0, 10, Time.now
  loop {
    Graphics.update
    @sprite.angle += 1
    i += 1
    if i == m
      t2 = Time.now
      p m/(t2-t)
      i, t = 0, t2
    end
  }
}