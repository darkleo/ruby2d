# Mandelbrot

require '../lib/ruby2D'
require 'complex'

Max = 100
def is_in_M? x, y
  c = Complex x, y
  k, z = 0, c
  #~ c = Complex 0.35, 0.05
  #~ c = Complex 0.28, 0.53
  #~ c = Complex -0.414, -0.612
  c = Complex -0.181, -0.667
  while z.abs2 < 4 and k < Max
    z = z*z + c
    k = k+1
  end
  k
end
def is_in_M2? x, y
  cr, ci = x, y
  k, zr, zi = 0, cr, ci
  #~ cr, ci = 0, 0
  cr, ci = -0.181, -0.667
  while zr**2+zi**2 < 4 and k < Max
    zr, zi = zr**2 - zi**2 + cr, 2*zr*zi + ci
    k = k+1
  end
  k
end

include Ruby2D
Size = 256
Window.name = 'Mandelbrot'
Window.resize Size, Size
Window.run {
  Graphics.framerate = 1.0/0
  @sprite = Sprite.new
  @sprite.bitmap = Bitmap.new Size, Size
  #~ c = Color.rand
  c = Color.rgb 250, 250, 250
  t = Time.now
  Size.times {|i|
    Size.times {|j|
      k = is_in_M2? 2.0*i/Size-1, 2.0*j/Size-1
      @sprite.bitmap.set_pixel i, j, c if k == Max
      next if k == Max
      @sprite.bitmap.set_pixel i, j, Color.rgb(0, 0, 50+205.0*k/Max)
      #~ @sprite.bitmap.draw_pixel i, j, Color.rgb(0, 0, 50+205.0*(1-0.85**k))
      Graphics.update
    }
    Graphics.update
  }
  p Time.now - t
}
