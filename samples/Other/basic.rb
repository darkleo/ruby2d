# To change this template, choose Tools | Templates
# and open the template in the editor.

require '../uby2d'

Cache.add_location 'Other/'
app = Application.new :name => 'light', :width => 128, :height => 128
app.launch {
  @sprite = Sprite.new :texture => Texture.new('Star.bmp')
  @sprite.ox = @sprite.oy =  @sprite.x = @sprite.y = 64
  loop {
    Graphics.update
    @sprite.angle += 1
  }
}