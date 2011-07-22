module Ruby2D
class Sprite < Graphic
  attr_reader :name, :id
  attr_accessor :rect
  attr_reader :bitmap
  attr_accessor :blend_type
  @@blend_type = 0
  
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
    @zoom_x  = 1
    @zoom_y  = 1
    @opacity = 100
    @color = Color.gray 255
    @visible = false
    @blend_type = 0
    case args.size
    when 0 # Default
      self.bitmap = Bitmap.new
      Ruby2D::Graphics.main_frame << self
    when 1
      case args[0]
      when Frame
        args[0] << self
        @belongs_to = args[0]
        self.bitmap = Bitmap.new
      when Bitmap
        self.bitmap = args[0]
        Ruby2D::Graphics.main_frame << self
      else
        fail TypeError
      end
    when 2
      args[0] << self
      @belongs_to = args[0]
      self.bitmap = args[1]
    else
      fail ArgumentError, 'wrong number of arguments'
    end
    @rect = Rect.new(0, 0, @bitmap.width, @bitmap.height)
    create_id
    @visible = true
  end

  def bitmap= bitmap
    return if @bitmap == bitmap
    @bitmap = bitmap
    @rect = Rect.new(0, 0, @bitmap.width, @bitmap.height)
  end
  
  def output
    return if !@visible || @opacity.zero?
    
    GL.PushMatrix
    GL.Translate(@x, -@y, 0)
    GL.Rotate(@angle, 0, 0, 1) if @angle != 0
    GL.Scale(@zoom_x, @zoom_y, 1)
    GL.Translate(-@ox, @oy, 0)
    GL.Color(@color.r/255.0, @color.g/255.0, @color.b/255.0, @opacity/100.0)
    
    @bitmap.use
    bw = @bitmap.width
    bh = @bitmap.height
    rw = @rect.width
    rh = @rect.height
    c = @rect.coords.collect {|t| [t[0].to_f/bw, t[1].to_f/bh]}
    
    blend_helper
    
    GL.Begin(GL::QUADS)
      GL.TexCoord2f(*c[0]) ; GL.Vertex3f(0, 0, 0)
      GL.TexCoord2f(*c[1]) ; GL.Vertex3f(rw, 0, 0)
      GL.TexCoord2f(*c[2]) ; GL.Vertex3f(rw, -rh, 0)
      GL.TexCoord2f(*c[3]) ; GL.Vertex3f(0, -rh, 0)
    GL.End
    GL.PopMatrix
  end
  
  private
  def blend_helper
    return if @blend_type == @@blend_type
    @@blend_type = @blend_type
    types = case @blend_type
      when 0 ; [GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA]
      when 1 ; [GL::SRC_ALPHA, GL::ONE]
      #~ when 2 ; [GL::ONE_MINUS_SRC_ALPHA, GL::ONE]
    end
    GL.BlendFunc(*types)
  end
  
  # TODO : change @@Max_IDS
  @@Max_IDS ||= 0
  def create_id
    @id = @@Max_IDS += 1
    @name ||= 'Spr' + @id.to_s
  end
end
end