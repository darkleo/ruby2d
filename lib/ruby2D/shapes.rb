# A superclass that handles shapes like squares, rectangles, discs...
class Shape
  attr_accessor :x, :y
  def initialize
    @x, @y, @ox, @oy, @angle = 0, 0, 0, 0, 0
  end
  def include? arg
    self === arg
  end
  def move x, y
    shape = self.dup
    shape.move! x, y
  end
  def move! x, y
    @x, @y = x, y
    self
  end
  def translate x, y
    shape = self.dup
    shape.translate! x, y
  end
  def translate! x, y
    @x += x
    @y += y
    self
  end
  def rotate angle
    shape = self.dup
    shape.rotate! angle
  end
  def rotate! angle
    @angle += angle
    self
  end
end

# The rectangle class.
class Rect < Shape
  attr_accessor :width, :height
  attr_accessor :ox, :oy, :angle
  # Create a new Rect object.
  #
  # args can be :
  # * (defaults arguments)
  # * x..x2, y..y2
  # * width, height
  # * x, y, width, height
  # * x, y, width, height, ox, oy, angle
  def initialize *args
    case args.size
    when 0
      @x, @y, @width, @height, @ox, @oy, @angle = 0, 0, 1, 1, 0, 0, 0
    when 2
      if args.all? {|x| x.class == Range}
        @x = args[0].first
        @width = args[0].last - @x
        @y = args[1].first
        @height = args[1].last - @y
      else
        @width, @height = *args
        @x, @y = 0, 0
      end
      @ox, @oy, @angle = 0, 0, 0
    when 4
      if args.all? {|x| Numeric === x}
        @x, @y, @width, @height = *args
        @ox, @oy = 0, 0
      else
        @x = args[0].first
        @width = args[0].last - @x
        @width += 1 unless args[0].exclude_end?
        @y = args[1].first
        @height = args[1].last - @y
        @height += 1 unless args[1].exclude_end?
        @ox, @oy = args[2, 2]
      end
      @angle = 0
    when 7
      @x, @y, @width, @height, @ox, @oy, @angle = *args
    else
      fail ArgumentError, 'wrong number of arguments'
    end
    self
  end
  
  # Return vertex coordinates
  #
  # [[x,y], [x,y], [x,y], [x,y]]
  def coords
    # TODO : improve calcul
    # TODO : save result
    return [[@x, @y],
            [@x+@width, @y],
            [@x+@width, @y+@height],
            [@x, @y+@height]
           ] if @angle == 0
    orig = Complex(@ox, @oy)
    eip = Complex.polar(1, @angle*Math::PI/180) # e^(i*phi)
    c1 = (Complex(@x, @y)-orig)*eip+orig
    c2 = (Complex(@x+@width, @y)-orig)*eip+orig
    c3 = (Complex(@x+@width, @y+@height)-orig)*eip+orig
#    c4 = ((Complex(@x, @y+@height)-orig)*eip+orig).rect
    return [c1.rect, c2.rect, c3.rect, (c3 - c2 + c1).rect]
  end
  def === *args
    # TODO : === with @angle
    case args[0]
    when Array
      r1 = @x..(@x+@width)
      r2 = @y..(@y+@height)
      return (r1 === args[0][0] and r2 === args[0][1])
    when Numeric
      return false unless @x..(@x+@width) === args[0]
      return false unless @y..(@y+@height) === args[1]
      return true
    else
      fail TypeError
    end
  end
end

# The square class.
class Square < Rect
  attr_accessor :size
  alias :width :size
  alias :width= :size=
  alias :height :size
  alias :height= :size=
  # Create a new Square object.
  def initialize size=1, angle=0
    super()
    @size = size
    @angle = angle
    self
  end
end

# The disc class.
class Disc < Shape
  attr_accessor :radius
  # Create a new Disc object.
  def initialize radius=1
    super()
    @radius = radius
    self
  end
  def === *args
    (args[0][0]-@x)**2+(args[0][1]-@y)**2 <= @radius**2
  end
end