# Bitmap#blt tests

$:.insert 0, '../lib/'
require 'ruby2D'
include Ruby2D

Cache.add_location 'Media/'
Window.name = 'Bitmap#blt'
Window.resize 516, 384
Window.run do
  bitmap1 = Bitmap.new 'blt1'
  bitmap2 = Bitmap.new 'blt2'
  rect = Rect.new 0..127, 0..127
  
  back = Bitmap.new 516, 384
  back.fill Color.rgb 255, 255, 255

  bitmap = Bitmap.new 516, 384
  bitmap.blt bitmap2, rect,  0,    0 # => :source
  bitmap.blt bitmap1, rect, 128,   0 # => :destination
  # back
  rect.translate 128, 0
  bitmap.blt bitmap1,  rect, 256,   0, :source
  bitmap.blt bitmap1,  rect, 384,   0, :source
  bitmap.blt bitmap1,  rect,   0, 128, :source
  bitmap.blt bitmap1,  rect, 128, 128, :source
  bitmap.blt bitmap1,  rect, 256, 128, :source
  bitmap.blt bitmap1,  rect, 384, 128, :source
  bitmap.blt bitmap1,  rect,   0, 256, :source
  bitmap.blt bitmap1,  rect, 128, 256, :source
  bitmap.blt bitmap1,  rect, 256, 256, :source
  bitmap.blt bitmap1,  rect, 384, 256, :source
  # tests
  rect.translate -128, 0
  bitmap.blt bitmap2, rect, 256,   0, :source_over
  bitmap.blt bitmap2, rect, 384,   0, :destination_over
  bitmap.blt bitmap2, rect,   0, 128, :source_in
  bitmap.blt bitmap2, rect, 128, 128, :destination_in
  bitmap.blt bitmap2, rect, 256, 128, :source_out
  bitmap.blt bitmap2, rect, 384, 128, :destination_out
  bitmap.blt bitmap2, rect,   0, 256, :source_atop
  bitmap.blt bitmap2, rect, 128, 256, :destination_atop
  bitmap.blt bitmap2, rect, 256, 256, :clear
  bitmap.blt bitmap2, rect, 384, 256, :xor
  
  @back = Sprite.new back
  @sprite = Sprite.new bitmap
  
  loop {Graphics.update}
end