# Mandelbrot

require '../lib/ruby2D'
#~ require 'complex'

class Fractal
  Size = 512
  Scale = 2.8
  #~ Origin = [-0.75, 0]
  Origin = [0, 0]
  Type = :julia
  #~ Cr, Ci = -0.122, 0.744 # lapin
  #~ Cr, Ci = -1, 0 # basilique
  #~ Cr, Ci = -0.75, 0 # San Marco
  #~ Cr, Ci = -1.7548, 0 # avion
  #~ Cr, Ci = 0.25, 0 # chou-fleur
  #~ Cr, Ci = -2, 0 # ... (mettre gros CCoef)
  Cr, Ci = -0.181, -0.667
  
  IInit = 50
  IMax = 150
  IDelta = 50
  
  CInit = rand#0.4
  CCoef = 0.007
  
  def initialize
    @sprite = Sprite.new
    @bitmap = Bitmap.new Size, Size
    @sprite.bitmap = @bitmap
    @hash = {}
    
    @iter = case Type
    when :julia
      lambda {|k,i,j,x,y| julia?(k,x,y)}
    when :mandelbrot
      lambda {|k,i,j,x,y| mandelbrot?(k,Origin.first+Scale*(i*1.0/Size-0.5), Origin.last+Scale*(j*1.0/Size-0.5),x,y)}
    end
    
    @imax = IInit
    Size.times do |j|
      Size.times do |i|
        k, x, y = @iter.(0, i, j, Origin.first+Scale*(i*1.0/Size-0.5), Origin.last+Scale*(j*1.0/Size-0.5))
        if k == @imax
          @hash[[i,j]] = [x,y] if IInit != IMax
        else
          @bitmap.set_pixel i, j, Color.rainbow(CInit + CCoef*k)
          Graphics.update
        end
      end
    end
  end
  def update
    return if @imax >= IMax
    @imax += IDelta
    @hash.each_pair do |(i,j),(x,y)|
        k, x, y = @iter.(0, i, j, Origin.first+Scale*(i*1.0/Size-0.5), Origin.last+Scale*(j*1.0/Size-0.5))
      if k == @imax
        @hash[[i,j]] = [x,y]
      else
        @hash.delete [i,j]
        @bitmap.set_pixel i, j, Color.rainbow(CInit + CCoef*k)
      end
      Graphics.update
    end
    
  end
  
  def mandelbrot? k, i, j, zr, zi
    while zr**2+zi**2 < 4 and k < @imax
      zr, zi = zr**2 - zi**2 + i, 2*zr*zi + j
      k += 1
    end
    return k, zr, zi
  end
  def julia? k, zr, zi
    while zr**2+zi**2 < 4 and k < @imax
      zr, zi = zr**2 - zi**2 + Cr, 2*zr*zi + Ci
      k += 1
    end
    return k, zr, zi
  end
end

include Ruby2D
Window.name = 'Fractal'
Window.resize Fractal::Size, Fractal::Size
Window.run do
  Graphics.framerate = 1.0/0
  @plane = Fractal.new
  loop { @plane.update }
end
