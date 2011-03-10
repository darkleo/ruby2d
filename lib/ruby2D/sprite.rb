module Ruby2D
class Sprite < Graphic
  attr_reader :name, :id
  attr_accessor :rect
  attr_reader :bitmap # rect
  
  # Create a new Sprite object.
  #
  # args can be :
  # * ()
  # * frame
  # * bitmap
  # * frame, bitmap
  def initialize *args
    @x    = 0
    @y    = 0
    @z    = 0
    @ox   = 0
    @oy   = 0
    @angle   = 0
    @zoom_x  = 100
    @zoom_y  = 100
    @opacity = 100
    @visible = true
    @disposed = false
    case args.size
    when 0 # Default
      @bitmap = Bitmap.new
      Ruby2D::Graphics.main_frame << self
    when 1
      case args[0]
      when Frame
        args[0] << self
        @belongs_to = args[0]
        @bitmap = Bitmap.new
      when Bitmap
        @bitmap = args[0]
        Ruby2D::Graphics.main_frame << self
      else
        fail TypeError
      end
    when 2
      args[0] << self
      @belongs_to = args[0]
      @bitmap = args[1]
    else
      fail ArgumentError, 'wrong number of arguments'
    end
    @rect = Rect.new(0, 0, @bitmap.width, @bitmap.height)
    create_id
  end
  def dispose
    @disposed = true
  end

  def bitmap= bitmap
    return if @bitmap == bitmap
    @bitmap = bitmap
    @rect = Rect.new(0, 0, @bitmap.width, @bitmap.height)
  end
  
  def output # intern use ONLY
    return if @disposed
    return unless @bitmap
    return unless @visible
    return unless @opacity != 0
    
    GL.PushMatrix
    GL.Translate(@x, -@y, 0)
    GL.Rotate(@angle, 0, 0, 1) if @angle != 0
    GL.Scale(@zoom_x/100.0, @zoom_y/100.0, 1)
    GL.Translate(-@ox, @oy, 0)
    GL.Color(1.0, 1.0, 1.0, @opacity/100.0) # TODO : @color
    
    @bitmap.use
    
    w = @rect.width
    h = @rect.height
    c1, c2, c3, c4 = *@rect.coords.map {|t| [t[0].to_f/w, t[1].to_f/h]}
    
    GL.Begin(GL::QUADS)
      GL.TexCoord2f(*c1) ; GL.Vertex3f(0, 0, 0)
      GL.TexCoord2f(*c2) ; GL.Vertex3f(w, 0, 0)
      GL.TexCoord2f(*c3) ; GL.Vertex3f(w, -h, 0)
      GL.TexCoord2f(*c4) ; GL.Vertex3f(0, -h, 0)
    GL.End
    GL.PopMatrix
  end
  
  private
  # TODO : change @@Max_IDS
  @@Max_IDS ||= 0
  def create_id
    @id = @@Max_IDS += 1
    @name ||= 'Spr' + @id.to_s
  end
end
end