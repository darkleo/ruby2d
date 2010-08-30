# Texture#blt tests

require 'uby2d'

Cache.add_location 'Media/'
app = Application.new :name => 'Texture#blt', :width => 516, :height => 384
app.launch {
  tex1 = Texture.new 'blt1.png'
  tex2 = Texture.new 'blt2.png'
  
  @s1 = Sprite.new :texture => tex1
  @s2 = Sprite.new :texture => tex2
  @s2.z = 10
  
  loop {
    Graphics.update
    @s1.z += 1
    p @s1.z
  }
}