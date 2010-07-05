# Texture#blt tests

require 'uby2d'

Cache.add_location 'Media/'
app = Application.new :name => 'Texture#blt', :width => 516, :height => 384
app.launch {
  tex1 = Texture.new 'blt1.png'
  tex2 = Texture.new 'blt2.png'
  rect = Rect.new 0..127, 0..127
  
  back = Texture.new 516, 384
  back.fill Color.new 255, 255, 255

  tex = Texture.new 516, 384
  tex.blt tex2, rect,  0,    0 # => :source
  tex.blt tex1, rect, 128,   0 # => :destination
  # back
  rect.translate 128, 0
  tex.blt tex,  rect, 256,   0, :source
  tex.blt tex,  rect, 384,   0, :source
  tex.blt tex,  rect,   0, 128, :source
  tex.blt tex,  rect, 128, 128, :source
  tex.blt tex,  rect, 256, 128, :source
  tex.blt tex,  rect, 384, 128, :source
  tex.blt tex,  rect,   0, 256, :source
  tex.blt tex,  rect, 128, 256, :source
  tex.blt tex,  rect, 256, 256, :source
  tex.blt tex,  rect, 384, 256, :source
  # tests
  rect.translate -128, 0
  tex.blt tex2, rect, 256,   0, :source_over
  tex.blt tex2, rect, 384,   0, :destination_over
  tex.blt tex2, rect,   0, 128, :source_in
  tex.blt tex2, rect, 128, 128, :destination_in
  tex.blt tex2, rect, 256, 128, :source_out
  tex.blt tex2, rect, 384, 128, :destination_out
  tex.blt tex2, rect,   0, 256, :source_atop
  tex.blt tex2, rect, 128, 256, :destination_atop
  tex.blt tex2, rect, 256, 256, :clear
  tex.blt tex2, rect, 384, 256, :xor
  
  @back = Sprite.new :texture => back
  @sprite = Sprite.new :texture => tex
  
  popup 'fini'
  loop {
    Graphics.update
    sleep 0.02
  }
}