# Space
# By Darkleo

require '../../lib/ruby2D'
include Ruby2D
Cache.add_location 'Space/'

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
class Planet
  attr_accessor :position, :sprite
  attr_accessor :pos, :vit, :mass
  def initialize name, pos, vit, mass
    @pos = pos
    @vit = vit
    @mass = mass
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new(name+'.png')
  end
  def distance_from planet
    (@pos - planet.pos).norm
  end
  def vect_to planet
    (@pos - planet.pos).normalize!
  end
end

#~Graphics.framerate = 1.0/0
Window.name = 'Space'
Window.run do
  tstar = Bitmap.new('Star.bmp')
  150.times do
    s = Sprite.new
    s.bitmap = tstar
    s.x = rand(640)
    s.y = rand(480)
    s.ox = s.oy = 64
    s.zoom = rand(10)+1
  end
  
  earth = Planet.new 'Earth', C.new, C.new, 6e24
  earth.sprite.ox = earth.sprite.oy = 64
  moon = Planet.new 'Moon', C.new(3e5), C.new(0, -30), 2e17
  moon.sprite.ox = moon.sprite.oy = 64
  moon.sprite.zoom = 33
  
  G = 6.674e-11
  dt = 100
  
  loop do
    f = G*earth.mass*moon.mass/((earth.distance_from(moon)*1000)**2)
    d = earth.vect_to moon
    earth.vit -= d*f*dt/earth.mass
    moon.vit += d*f*dt/moon.mass
    earth.pos += earth.vit*dt
    moon.pos += moon.vit*dt
    earth.sprite.x = 320+earth.pos.x/1000.to_i
    earth.sprite.y = 240+earth.pos.y/1000.to_i
    moon.sprite.x = 320+moon.pos.x/1000.to_i
    moon.sprite.y = 240+moon.pos.y/1000.to_i
    
    Graphics.update
  end
end
