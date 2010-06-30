# To change this template, choose Tools | Templates
# and open the template in the editor.

class Texture
  attr_reader :width, :height, :real_size
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
    
    unless @real_size
      @real_size  = 1
      @real_size *= 2 while @real_size < [@width, @height].max
    end
    @data ||= ([0]*@real_size**2*4).pack('C*')
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
      return Color.new(*@data[x-1+(y-1)*@width, 4].unpack('C*'))
    rescue
      fail 'pixel out of range'
    end
  end
  def draw_pixel x, y, c
    begin
      @data[x.to_i+y.to_i*@width, 4] = c.data.pack('C*')
    rescue
      fail 'pixel out of range'
    end
    @need_bind = true
  end
end