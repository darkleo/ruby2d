require '../lib/ruby2D'
include Ruby2D

Window.name = 'Light'
Window.resize 128, 128
Window.run do
  #~ Graphics.framerate = 120
  Graphics.framerate = Float::MAX
  @sprite = Sprite.new
  @sprite.bitmap = Bitmap.new 'Star'
  @sprite.ox = @sprite.oy = @sprite.x = @sprite.y = 64
  loop do
    Graphics.update
    @sprite.angle += 1
    #~ p @sprite.angle
  end
end
