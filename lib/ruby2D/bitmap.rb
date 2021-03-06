module Ruby2D
class Bitmap
  attr_reader :width, :height
  attr_reader :real_size, :data #...
  # Create a new Bitmap object.
  #
  # args can be :
  # * (defaults arguments)
  # * width, height
  # * x, y, width, height
  # * x, y, width, height, ox, oy, angle
  # * a Hash with all or part of the args
  def initialize *args
    @need_bind = true
    case args.size
    when 0
      @width, @height = 1, 1
    when 1 ## String || Hash
      case args[0]
      when String
        img = Ruby2D::Cache.load_bitmap args[0]
        @width = img.width
        @height = img.height
        @data = img.data
      when Hash
        hash = args[0]
        @name = hash[:name]||''
        @width = hash[:width]||0
        @height = hash[:height]||0
        @data = hash[:data]
      else
        fail TypeError
      end
    when 2 # Integer * 2
      @width, @height = *args
    when 3 # Integer * 2, String
      @width, @height, @data = *args
    else
      fail ArgumentError, 'wrong number of arguments'
    end
    @name ||= ''
    @data ||= Array.new(@height) {[0].pack('C')*@width*4}
    fail 'Invalid bitmap size' unless @data.join.size == @width*@height*4
  end
  DefaultFont = Font.new(File.join(File.dirname(__FILE__),'default'))
  
  def use
    unless @tex_id
      @tex_id = GL.GenTextures(1).first
      GL.BindTexture GL::TEXTURE_2D, @tex_id
      GL.TexParameter GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::NEAREST
      GL.TexParameter GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::NEAREST
      GL.TexParameter GL::TEXTURE_2D, GL::TEXTURE_WRAP_S,     GL::CLAMP_TO_EDGE
      GL.TexParameter GL::TEXTURE_2D, GL::TEXTURE_WRAP_T,     GL::CLAMP_TO_EDGE
    else
      GL.BindTexture GL::TEXTURE_2D, @tex_id
    end
    if @need_bind
      GL.TexImage2D GL::TEXTURE_2D, 0, GL::RGBA, @width, @height,
        0, GL::RGBA, GL::UNSIGNED_BYTE, @data.join
      @need_bind = false
    end
  end
  
  def get_pixel x, y
    begin
      fail IndexError if x<0||x>=@width||y<0||y>=@height
      Color.rgba(*@data[y][4*x, 4].unpack('C*'))
    rescue IndexError
      fail 'pixel out of range'
    end
  end
  def set_pixel x, y, c
    begin
      fail IndexError if x<0||x>=@width||y<0||y>=@height
      @data[y.to_i][4*x.to_i, 4] = c.rgba.pack 'C*'
    rescue IndexError
      fail 'pixel out of range'
    end
    @need_bind = true
  end
  alias_method :[], :get_pixel
  alias_method :[]=, :set_pixel
  
  # Modes are
  # * :source
  # * :dest
  # * :source_over
  # * :destination_over
  # * :source_in
  # * :destination_in
  # * :source_out
  # * :destination_out
  # * :source_atop
  # * :destination_atop
  # * :clear
  # * :xor
  def blt bitmap, rect, x, y, mode=:source_over
    case mode
    when :source
      h = [@height-y, rect.height].min
      w = [@width-x, rect.width].min
      for j in 0...h
        @data[y+j][4*x, 4*w] = bitmap.data[rect.y+j][4*rect.x, 4*w]
      end
    when :dest
      # nada
    when :source_over
      h = [@height-y, rect.height].min
      w = [@width-x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*a1*a2+src[0]*(1-a2)+dest[0]*(1-a1)
          g = src[1]*a1*a2+src[1]*(1-a2)+dest[1]*(1-a1)
          b = src[2]*a1*a2+src[2]*(1-a2)+dest[2]*(1-a1)
          a = a1*a2+a1*(1-a2)+a2*(1-a1)
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_over
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*a1*a2+src[0]*(1-a2)+dest[0]*(1-a1)
          g = dest[1]*a1*a2+src[1]*(1-a2)+dest[1]*(1-a1)
          b = dest[2]*a1*a2+src[2]*(1-a2)+dest[2]*(1-a1)
          a = a1+a2-a1*a2
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :source_in
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*a1*a2
          g = src[1]*a1*a2
          b = src[2]*a1*a2
          a = a1*a2
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_in
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*a1*a2
          g = dest[1]*a1*a2
          b = dest[2]*a1*a2
          a = a1*a2
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :source_out
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*(1-a2)
          g = src[1]*(1-a2)
          b = src[2]*(1-a2)
          a = a1*(1-a2)
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_out
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*(1-a1)
          g = dest[1]*(1-a1)
          b = dest[2]*(1-a1)
          a = a2*(1-a1)
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :source_atop
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*a1*a2+dest[0]*(1-a1)
          g = src[1]*a1*a2+dest[1]*(1-a1)
          b = src[2]*a1*a2+dest[2]*(1-a1)
          a = a2
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_atop
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*a1*a2+src[0]*(1-a2)
          g = dest[1]*a1*a2+src[1]*(1-a2)
          b = dest[2]*a1*a2+src[2]*(1-a2)
          a = a1
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :clear
      clear rect.dup.translate(x, y)
    when :xor
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = bitmap.data[rect.y+j][4*(rect.x+i), 4].unpack 'C*'
          dest = @data[y+j][4*(x+i), 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*(1-a2)+dest[0]*(1-a1)
          g = src[1]*(1-a2)+dest[1]*(1-a1)
          b = src[2]*(1-a2)+dest[2]*(1-a1)
          a = a1*(1-a2)+a2*(1-a1)
          @data[y+j][4*(x+i), 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    else
      fail "mode :#{mode} unknow in Bitmap#blt"
    end
    @need_bind = true
  end
  def fill *args
    color = rect = nil
    case args.size
    when 1
      rect = Rect.new 0...@width, 0...@height
      color = args[0]
    when 2
      rect, color = *args
    end
    str = color.rgba.pack 'C*'
    w = [@width-rect.x, rect.width].min
    h = [@height-rect.y, rect.height].min
    full = str*w
    for j in 0...h
      @data[rect.y+j][4*rect.x, 4*w] = full
    end
    @need_bind = true
  end

  def clear rect=nil
    rect ||= Rect.new(0...@width, 0...@height)
    w = [@width-rect.x, rect.width].min
    h = [@height-rect.y, rect.height].min
    full = "\x00"*4*w
    for j in 0...h
      @data[rect.y+j][4*rect.x, 4*w] = full
    end
    @need_bind = true
  end
  
  def draw_text str, x=0, y=0, font=DefaultFont, mode=:source_over
    bitmap = font.render str
    rect ||= Rect.new(0...bitmap.width, 0...bitmap.height)
    blt bitmap, rect, x, y, mode
  end
end
end