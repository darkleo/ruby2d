require '../lib/ruby2D'
include Ruby2D

Window.name = 'Light'
Window.resize 128, 128
Window.run do
  @sprite = Sprite.new
  @sprite.bitmap = Bitmap.new 'Star.png'
  @sprite.ox = @sprite.oy = @sprite.x = @sprite.y = 64
  loop do
    Graphics.update
    @sprite.angle += 1
  end
end
