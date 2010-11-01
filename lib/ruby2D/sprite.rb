class Sprite < Graphic
  attr_reader :name, :id
  attr_accessor :x, :y
  attr_reader :z # Graphics.sort!
  attr_accessor :ox, :oy, :angle
  attr_accessor :rect
  attr_accessor :zoom_x, :zoom_y
  attr_accessor :opacity
  attr_accessor :visible
  attr_reader :bitmap # rect
  
  # Create a new Sprite object.
  #
  # args can be :
  # * (defaults arguments)
  # * bitmap
  # * a Hash with all or part of the args
  def initialize *args
    case args.size
    when 0 # Default
      @name = ''
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
      @bitmap = Bitmap.new
      @rect = Rect.new @bitmap.width, @bitmap.height
    when 1
      case args[0]
      when Hash
        hash = args[0]
        @name = hash[:name]
        @x    = hash[:x]||0
        @y    = hash[:y]||0
        @z    = hash[:z]||0
        @ox   = hash[:ox]||0
        @oy   = hash[:oy]||0
        @angle   = hash[:angle]||0
        @zoom_x  = hash[:zoom_x]||hash[:zoom]||100
        @zoom_y  = hash[:zoom_y]||hash[:zoom]||100
        @opacity = hash[:opacity]||100
        @visible = hash[:visible].nil? ? true : hash[:visible].nil?
        @bitmap = hash[:bitmap]||Bitmap.new
        @rect = hash[:rect]||Rect.new(@bitmap.width, @bitmap.height)
      when Bitmap
        @name = ''
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
        @bitmap = args[0]
        @rect = Rect.new(0, 0, @bitmap.width, @bitmap.height)
      else
        fail 'Argument error in Sprite#initialize'
      end
    else
      fail 'Bad number of arguments in Sprite#initialize'
    end
    create_id
    Graphics.add self
    @deleted = false
  end
  def dispose
    Graphics.remove self
    @deleted = true
  end

  def <=> graph
    self.z <=> graph.z
  end
  def update
    return if @deleted
  end

  def z= z
    @z = z
    Graphics.sort!
  end
  def bitmap= bitmap
    return if @bitmap == bitmap
    @bitmap = bitmap
    @rect = Rect.new(0, 0, @bitmap.width, @bitmap.height)
  end

  def output # intern use ONLY
    return unless @bitmap
    return unless @visible
    return if @opacity == 0

    GL.LoadIdentity
    GL.Translate(@x, -@y, 0)
    GL.Scale(@zoom_x/100.0, @zoom_y/100.0, 1)
    GL.Rotate(@angle, 0, 0, 1) if @angle != 0
    GL.Translate(-@ox, @oy, 0)
    
    GL.Color 1, 1, 1, @opacity/100.0
    
    @bitmap.use
    
    w = @rect.width
    h = @rect.height
    s = @bitmap.real_size.to_f
    c1, c2, c3, c4 = *@rect.coords.map {|t| [t[0]/s, t[1]/s]}
    
    GL.Begin(GL::QUADS)
    GL.TexCoord2f(*c1) ; GL.Vertex3f(0, 0, 0)
    GL.TexCoord2f(*c2) ; GL.Vertex3f(w, 0, 0)
    GL.TexCoord2f(*c3) ; GL.Vertex3f(w, -h, 0)
    GL.TexCoord2f(*c4) ; GL.Vertex3f(0, -h, 0)
    GL.End
  end
  
  private
  # TODO : change @@Max_IDS
  @@Max_IDS ||= 0
  def create_id
    @id = @@Max_IDS += 1
    @name ||= "Spr#{@id}"
  end
end