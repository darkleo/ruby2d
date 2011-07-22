#! /home/blot/.rvm/bin/ruby
# Space
# By Darkleo

require '../lib/ruby2D'
require 'ap'
include Ruby2D

class C
  attr_accessor :x, :y, :z
  def initialize(x=0, y=0, z=0)
    @x, @y, @z = x, y, z
  end
  def -@
    C.new(-@x, -@y, -@z)
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
  def coerce other
    return self, other
  end
  def norm2
    @x**2+@y**2+@z**2
  end
  def norm
    Math.sqrt norm2
  end
  def clear
    @x *= 0
    @y *= 0
    @z *= 0
  end
  def inspect
    "[\s#@x,\n\s\s#@y,\n\s\s#@z]"
  end
end

class Arrow
  attr_accessor :x, :y, :lenght, :angle, :visible
  attr_reader :zoom
  red = Color.rgb(255, 0, 0)
  Head_Bitmap = Bitmap.new 10, 10
  5.times {|i| (5-i).times {|j| Head_Bitmap.set_pixel 5-j, i, red ; Head_Bitmap.set_pixel 4+j, i, red }}
  def initialize
    @head = Sprite.new
    @head.bitmap = Head_Bitmap
    @head.ox = 5
    @body = Sprite.new
		@body.bitmap = Bitmap.new 1, 10
		@body.bitmap.fill Color.rgb(255, 0, 0)
    
    @x = 0
    @y = 0
    @zoom = 1
    @lenght = 10
    @angle = 0
    @visible = true
  end
  def belongs_to space
    space.frame << @head
    space.frame << @body
    self.zoom = 1/space.frame.zoom
  end
  def zoom= z
    @zoom = z
    @head.zoom = @zoom
    @body.zoom = @zoom
  end
  def update
    @body.visible = @head.visible = @visible
    return unless @visible
    @body.x = @head.x = @x
    @body.y = @head.y = @y
    @head.oy = -@lenght
    @body.zoom_y = @zoom*@lenght/10
    @body.angle = @head.angle = @angle
  end
  def dispose
    @head.dispose
    @body.dispose
  end
end

class Planet
  attr_accessor :sprite
  attr_accessor :pos, :vit, :mass, :radius
  White = Color.rgb(255, 255, 255)
  def initialize pos, vit, mass, radius=((mass/((1+rand)*4000*Math::PI))**(0.33)).to_i
    # 1000 < radius < 100000 km
    @pos = pos
    @vit = vit
		@acc = C.new
    @mass = mass
		@radius = radius
    @sprite = Sprite.new
    s = Math.log10(@radius).to_i
    @sprite.bitmap = Bitmap.new 2**(s-5), 2**(s-5)
    @sprite.bitmap.fill Color.rand
    @sprite.z = 10
		@sprite.ox = @sprite.oy = 2**(s-6)
    @arrow_vit = Arrow.new
    @trail = (1..200).map do |i|
      sprite = Sprite.new
      sprite.bitmap = Bitmap.new
      sprite.bitmap.set_pixel 0, 0, White
      sprite
    end
  end
  def belongs_to space
    @space = space
    @space.frame << @sprite
    @arrow_vit.belongs_to @space
    @trail.each {|particule| @space.frame << particule }
    update_zoom
  end
  def update_zoom
    zoom = 1/@space.frame.zoom
    @sprite.zoom = zoom
    @arrow_vit.zoom = zoom
    @trail.each {|particule| particule.zoom = zoom }
  end
	def update_vit planets
    @acc.clear
    planets.each do |other_planet|
			next if self == other_planet
			delta = @pos-other_planet.pos
			dist = delta.norm
      if [dist, (delta+@vit*@space.dt).norm].min < radius+other_planet.radius
        crash planets, other_planet
        return
      end
			@acc -= @space.g*other_planet.mass*delta/(dist**3)
		end
	end
	def update_pos
    @trail << @trail.shift
    @trail.last.x = @pos.x
    @trail.last.y = @pos.y
    @trail.each_with_index {|sp, i| sp.opacity = i/1.5}
    
    error = case
      when @vit.norm2 > 9e16 # 1%*c²
        'Relativistic object'
      #~ when @acc.norm2*@space.dt < @vit.norm2*1e-12 #...
        #~ 'Lost in Space'
      end
    if error
      puts error
      dispose
      @space.unlock self
      @space.planets.delete self
    end
		@vit += @acc*@space.dt
		@pos += @vit*@space.dt
    @sprite.x = @arrow_vit.x = @pos.x
    @sprite.y = @arrow_vit.y = @pos.y
    @arrow_vit.lenght = @vit.norm/400
    @arrow_vit.visible = @vit.norm/4 > 100
		@arrow_vit.angle = 180*Math.atan2(@vit.x, @vit.y)/Math::PI
    @arrow_vit.update
	end
	def crash planets, other_planet
		puts 'CRASH!!!'
		pos = (@pos+other_planet.pos)/2
		mass = @mass + other_planet.mass
		vit = (@mass*@vit+other_planet.mass*other_planet.vit)/mass
    other_planet.dispose
		planets.delete other_planet
    dispose
		planets.delete self
    new_planet = Planet.new(pos, vit, mass)
    new_planet.belongs_to @space
		planets << new_planet
	end
	def dispose
		@sprite.dispose
    @arrow_vit.dispose
    @trail.each(&:dispose)
	end
  def inspect
    "<\#Planet:#{__id__}>"
  end
end

class Space
  attr_reader :planets
  attr_accessor :g, :dt
  attr_accessor :frame
  def initialize
    @frame = Frame.new
    @frame.ox = -320/@frame.zoom
    @frame.oy = -240/@frame.zoom
    @planets = []
    @g = 6.674e-11
    @dt = 3600 # 1h
  end
  def update
    @planets.each {|planet| planet.update_vit @planets}
    @planets.map {|planet| planet.update_pos}
    return unless @locked_on
    @frame.ox = @locked_on.pos.x - 320/@frame.zoom
    @frame.oy = @locked_on.pos.y - 240/@frame.zoom
  end
  def << planet
    planet.belongs_to self
    @planets << planet
  end
  def lock planet
    @locked_on = planet
  end
  def unlock planet=nil
    return if planet && (@lock_on == planet)
    @locked_on = nil
  end
  def zoom
    @frame.zoom
  end
  def zoom= z
    @frame.zoom = z
    @planets.each {|planet| planet.update_zoom}
  end
  
  def scenario title
    return yield if block_given?
    puts "Preparing scenario..."
    case title
    when 'earth'
      @frame.zoom = 1e-6/2
      @dt = 3600 # 1h
      self << Planet.new(C.new(0, 0, 0),
                        C.new(0, 0, 0),
                        5.97e24,
                        6.37e6)
      self << Planet.new(C.new(3.84e8, 0, 0),
                        C.new(0, -1e3, 0),
                        7.3e22)
      lock @planets.first
    when 'sun'
      @frame.zoom = 1e-10
      @dt = 24*3600
      # Sun
      self << Planet.new(C.new(0, 0, 0),
                        C.new(0, 0, 0),
                        2e30,
                        6.96e8)
      # Mercury
      self << Planet.new(C.new(5.79e10, 0, 0),
                        C.new(0, 4.7e4, 0),
                        3.3e21,
                        2.44e6)
      # Venus
      self << Planet.new(C.new(1.08e11, 0, 0),
                        C.new(0, 3.5e4, 0),
                        4.86e24,
                        6.05e6)
      # Earth
      self << Planet.new(C.new(1.5e11, 0, 0),
                        C.new(0, 2.98e4, 0),
                        5.97e24,
                        6.38e6)
      # Mars
      self << Planet.new(C.new(2.3e11, 0, 0),
                        C.new(0, 2.41e4, 0),
                        6.42e23,
                        3.39e6)
      # Jupiter
      self << Planet.new(C.new(7.78e11, 0, 0),
                        C.new(0, 1.3e4, 0),
                        1.90e27,
                        7.15e7)
      # Saturn
      self << Planet.new(C.new(1.42e12, 0, 0),
                        C.new(0, 9.64e3, 0),
                        5.68e26,
                        6.02e7)
      # Uranus
      self << Planet.new(C.new(2.88e12, 0, 0),
                        C.new(0, 6.81e3, 0),
                        8.68e25,
                        2.56e7)
      # Neptune
      self << Planet.new(C.new(4.5e12, 0, 0),
                        C.new(0, 5.43e3, 0),
                        1.02e26,
                        2.48e7)
      lock @planets[3]
    when 'accretion'
      @frame.zoom = 1e-6/2
      (20).to_i.times do
        self << Planet.new(C.new((2*rand-1)*384_400_000, (2*rand-1)*384_400_000), C.new, 6e22)
        p 'one more'
      end
      lock @planets.sample
    else
      puts 'Scenario : "'+title+'" unknown'
      return scenario 'earth'
    end
    puts 'Scenario : "'+title+'" launched'
  end
end

#~ Graphics.framerate = 2*24 # 2days/sec
Graphics.framerate = Float::MAX # 2days/sec
Window.name = 'Space'
Window.run do
  @space = Space.new
  title = ARGV.first || 'earth'
  @space.scenario title
  
  loop do
    @space.update
    Graphics.update
    Input.update
    @space.zoom += 1e-11 if Input.press? ?+
    @space.zoom -= 1e-11 if Input.press? ?-
    @space.lock @space.planets.shuffle.first if Input.trigger? ?\s
  end
end