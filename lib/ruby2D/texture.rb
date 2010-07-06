# To change this template, choose Tools | Templates
# and open the template in the editor.

class Texture
  attr_reader :width, :height
  attr_reader :real_size, :data #...
  def initialize *args
    case args.size
    when 1 ## String || Hash
      hash = args[0].class.to_s == 'String' ? Cache.load_texture(*args) : args[0]
      @name = hash[:name]||''
      @width = hash[:width]||0
      @height = hash[:height]||0
      @real_size ||= hash[:real_size]
      @data = hash[:data]||[]
    when 2 # Integer * 2
      @width, @height = *args
    when 3 # Integer * 3
      @width, @height, @name = *args
    end
    @name ||= ''
    @width ||= 0
    @height ||= 0

    # TODO : log2
    unless @real_size
      @real_size  = 1
      @real_size *= 2 while @real_size < [@width, @height].max
    end
    @data ||= "\x00"*@real_size**2*4
    fail 'Invalid size' unless @data.size == @real_size**2*4
    @need_bind = true
  end
  def update
    bind if @need_bind
  end

  def use
    GL.BindTexture(GL::TEXTURE_2D, @tex_id)
  end
  def bind
    @need_bind = false
    @tex_id ||= GL.GenTextures(1)[0]
    use
    return if @data.empty?
    # blur_more = GL::LINEAR or GL::NEAREST
    GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)
    GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR)
    GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA, @real_size, @real_size,
        0, GL::RGBA, GL::UNSIGNED_BYTE, @data)
  end

  def pixel x, y
    begin
      return Color.new *@data[4*x+4*y*@real_size, 4].unpack('C*')
    rescue
      fail 'pixel out of range'
    end
  end
  def draw_pixel x, y, c
    begin
      @data[4*x.to_i+4*y.to_i*@real_size, 4] = c.data.pack 'C*'
    rescue
      fail 'pixel out of range'
    end
    @need_bind = true
  end

  def blt texture, rect, x, y, mode=:source_over
    case mode
    when :source
      h = [@height-rect.y, texture.height-rect.x, rect.height].min
      for j in 0...h
        z_src  = 4*x+4*(y+j)*@real_size
        z_dest = 4*rect.x+4*(rect.y+j)*texture.real_size
        w = [@width-rect.x, texture.width-rect.x, rect.width].min
        @data[z_src, 4*w] = texture.data[z_dest, 4*w]
      end
    when :dest
      # nada
    when :source_over
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*a1*a2+src[0]*(1-a2)+dest[0]*(1-a1)
          g = src[1]*a1*a2+src[1]*(1-a2)+dest[1]*(1-a1)
          b = src[2]*a1*a2+src[2]*(1-a2)+dest[2]*(1-a1)
          a = a1*a2+a1*(1-a2)+a2*(1-a1)
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_over
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*a1*a2+src[0]*(1-a2)+dest[0]*(1-a1)
          g = dest[1]*a1*a2+src[1]*(1-a2)+dest[1]*(1-a1)
          b = dest[2]*a1*a2+src[2]*(1-a2)+dest[2]*(1-a1)
          a = a1+a2-a1*a2
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :source_in
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*a1*a2
          g = src[1]*a1*a2
          b = src[2]*a1*a2
          a = a1*a2
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_in
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*a1*a2
          g = dest[1]*a1*a2
          b = dest[2]*a1*a2
          a = a1*a2
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :source_out
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*(1-a2)
          g = src[1]*(1-a2)
          b = src[2]*(1-a2)
          a = a1*(1-a2)
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_out
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*(1-a1)
          g = dest[1]*(1-a1)
          b = dest[2]*(1-a1)
          a = a2*(1-a1)
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :source_atop
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*a1*a2+dest[0]*(1-a1)
          g = src[1]*a1*a2+dest[1]*(1-a1)
          b = src[2]*a1*a2+dest[2]*(1-a1)
          a = a2
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :destination_atop
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = dest[0]*a1*a2+src[0]*(1-a2)
          g = dest[1]*a1*a2+src[1]*(1-a2)
          b = dest[2]*a1*a2+src[2]*(1-a2)
          a = a1
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    when :clear
      clear rect.dup.translate(x, y)
    when :xor
      h = [@height-rect.y, rect.height].min
      w = [@width-rect.x, rect.width].min
      for j in 0...h
        for i in 0...w
          src = texture.data[4*(rect.x+i)+4*(rect.y+j)*texture.real_size, 4].unpack 'C*'
          dest = @data[4*(x+i)+4*(y+j)*@real_size, 4].unpack 'C*'
          a1 = src[3]/255.0
          a2 = dest[3]/255.0
          r = src[0]*(1-a2)+dest[0]*(1-a1)
          g = src[1]*(1-a2)+dest[1]*(1-a1)
          b = src[2]*(1-a2)+dest[2]*(1-a1)
          a = a1*(1-a2)+a2*(1-a1)
          @data[4*(x+i)+4*(y+j)*@real_size, 4] = [r, g, b, a*255].pack 'C*'
        end
      end
    else
      fail "mode :#{mode} unknow in Texture#blt"
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
      rect, color =  *args
    end
    str = color.data.pack 'C*'
    w = [@width-rect.x, rect.width].min
    h = [@height-rect.y, rect.height].min
    full = str*w
    for j in 0...h
      z = 4*rect.x+4*(rect.y+j)*@real_size
      @data[z, 4*w] = full
    end
    @need_bind = true
  end

  def clear rect=nil
    rect ||= Rect.new(0...@width, 0...@height)
    w = [@width-rect.x, rect.width].min
    h = [@height-rect.y, rect.height].min
    full = "\x00"*4*w
    for j in 0...h
      z = 4*rect.x+4*(rect.y+j)*@real_size
      @data[z, 4*w] = full
    end
    @need_bind = true
  end
end