# Space
# By Darkleo

$:.insert 0, '../../lib/'
require 'ruby2d'
require 'ap' #awesome_printer

Cache.add_location 'Space/'

class P
  attr_accessor :p, :v, :m
  def initialize(pos, vit, mass)
    @p = pos
    @v = vit
    @m = mass
  end
  def distance(point)
    (@p - point.p).norm
  end
  def vect(point)
    (@p - point.p).normalize!
  end
end
class C
  attr_accessor :x, :y, :z
  def initialize(x=0, y=0, z=0)
    @x = x
    @y = y
    @z = z
  end
  def +(coord)
    C.new(@x + coord.x, @y + coord.y, @z + coord.z)
  end
  def -(coord)
    C.new(@x - coord.x, @y - coord.y, @z - coord.z)
  end
  def *(scal)
    C.new(@x*scal, @y*scal, @z*scal)
  end
  def /(scal)
    C.new(@x/scal, @y/scal, @z/scal)
  end
  def norm
    Math.sqrt(@x**2+@y**2+@z**2)
  end
  def normalize!
    n = norm
    @x /= n
    @y /= n
    @z /= n
    return self
  end
end

#~ Graphics.framerate = 1.0/0
Window.name = 'Space'
Window.run do
  begin
  tstar = Bitmap.new('Star.bmp')
  150.times do
    r = rand(10)+1
    s = Sprite.new :bitmap => tstar,
    :x => rand(640), :y => rand(480),
    :ox => 64, :oy => 64, :zoom => r
  end
  s1 = Sprite.new :name => 'Earth',
    :bitmap => Bitmap.new('Earth.png'),
    :ox => 64, :oy => 64
  s2 = Sprite.new :name => 'Moon',
    :bitmap => Bitmap.new('Moon.png'),
    :ox => 64, :oy => 64, :zoom => 33
  #~ s2.set_update {@angle += 100*0.02}
  p1 = P.new(C.new, C.new, 6e24) # Terre
  p2 = P.new(C.new(3e5), C.new(0, -30), 2e17) # Lune
  G = 6.674e-11
  dt = 100
  
  loop do
    f = G*p1.m*p2.m/((p1.distance(p2)*1000)**2)
    d = p1.vect p2
    p1.v -= d*f*dt/p1.m
    p2.v += d*f*dt/p2.m
    p1.p += p1.v*dt
    p2.p += p2.v*dt
    s1.x = 320+p1.p.x/1000.to_i
    s1.y = 240+p1.p.y/1000.to_i
    s2.x = 320+p2.p.x/1000.to_i
    s2.y = 240+p2.p.y/1000.to_i
    
    Graphics.update
  end
  rescue => error
    p error
    ap error.backtrace
  end
end