# Texture#blt tests

require 'uby2d'

Cache.add_location 'Media/'
app = Application.new :name => 'Texture#blt', :width => 516, :height => 384
app.launch {
  tex1 = Texture.new 'blt1.png'
  b = !true
  if b
    @sprite = Sprite.new :texture => tex1
  else
    @sprite = Sprite.new
    @sprite.texture = tex1
    @sprite.rect = Rect.new(0, 0,64,64)
  end
  loop {Graphics.update}
}