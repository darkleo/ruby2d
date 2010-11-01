# Sprite#z tests

$:.insert 0, '../lib/'
require 'ruby2d'

Cache.add_location 'Media/'
Window.name = 'Sprite#z'
Window.resize 256, 128
Window.run {
  @s1 = Sprite.new Bitmap.new 'blt1.png' 
  @s2 = Sprite.new Bitmap.new 'blt2.png'
  
  loop {
    Graphics.update
    Mouse.update
    @s1.z = 160 - Mouse.x
  }
}