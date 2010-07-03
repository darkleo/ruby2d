# A superclass that handles shapes like squares, rectangles, discs...
class Shape
  attr_accessor :x, :y
  def include? arg
    self === arg
  end
  def translate x, y
    # TODO : ...
    @x += x
    @y += y
    self
  end
  def translate! x, y
    @x += x
    @y += y
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
  # * a Hash with all or part of the args
  def initialize *args
    case args.size
    when 0 # Default values
      @x, @y, @width, @height = 0, 0, 1, 1
      @ox, @oy, @angle = 0, 0, 0
    when 1 # Hash
      hash = *args
      @x      = hash[:x] || 0
      @y      = hash[:y] || 0
      @ox     = hash[:ox] || 0
      @oy     = hash[:oy] || 0
      @angle  = hash[:angle] || 0
      @width  = hash[:width] || 1
      @height = hash[:height] || 1
    when 2
      a1, a2 = *args
      if Range === a1 and Range === a2
        @x, @width = a1.first, a1.last - a1.first
        @width += 1 unless a1.exclude_end?
        @y, @height = a2.first, a2.last - a2.first
        @height += 1 unless a2.exclude_end?
      else
        @width, @height = a1, a2
        @x, @y, @ox, @oy, @angle = 0, 0, 0, 0, 0
      end
      @ox, @oy, @angle = 0, 0, 0
    when 4 # Integer * 4
      @x, @y, @width, @height = *args
      @ox, @oy, @angle = 0, 0, 0
    when 7 # Integer * 7
      @x, @y, @width, @height, @ox, @oy, @angle = *args
    else
      fail 'Bad number of arguments in Rect#initialize'
    end
    self
  end
  def data
    return [@x, @y, @width, @height]
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
      fail 'Argument error in Rect#==='
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
  #
  # args can be :
  # * (defaults arguments)
  # * x, y, size
  # * x, y, size, ox, oy, angle
  # * a Hash with all or part of the args
  def initialize *args
    case args.size
    when 0 # Default values
      @x, @y, @size = 0, 0, 1
      @ox, @oy, @angle = 0, 0, 0
    when 1 # Hash
      hash = *args
      @x      = hash[:x]||0
      @y      = hash[:y]||0
      @ox     = hash[:ox]||0
      @oy     = hash[:oy]||0
      @angle  = hash[:angle]||0
      @size   = hash[:size]||hash[:width]||hash[:height]||1
    when 3 # Integer * 3
      @x, @y, @size = *args
      @ox, @oy, @angle = 0, 0, 0
    when 7 # Integer * 6
      @x, @y, @size, @ox, @oy, @angle = *args
    else
      fail 'Bad number of arguments in Rect#initialize'
    end
    self
  end
end

# The disc class.
class Disc < Shape
  attr_accessor :radius
  # Create a new Disc object.
  # 
  # args can be :
  # * (defaults arguments)
  # * radius
  # * x, y, radius
  # * a Hash with all or part of the args
  def initialize *args
    case args.size
    when 0 # Default values
      @x, @y, @radius = 0, 0, 1
    when 1 # Numeric
      @x, @y, @radius = 0, 0, *args
    when 3 # Numeric * 3
      @x, @y, @radius = *args
    else
      fail 'Argument error in Disc#initialize'
    end
    self
  end
  def === *args
    case args.size
    when 1
      return (args[0][0]-@x)+(args[0][1]-@y) <= @radius
    when 2
      return (args[0]-@x)+(args[1]-@y) <= @radius
    else
      fail 'Argument error in Disc#==='
    end
  end
end