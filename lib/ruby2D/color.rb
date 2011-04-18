module Ruby2D
class Color
  attr_accessor :r, :g, :b, :a
  %w(r ed g reen b lue a lpha).each_slice(2) do |abb, full|
    alias_method abb+full, abb
    alias_method abb+full+?=, abb+?=
  end
  private_class_method :new
  def initialize r, g, b, a=255
    @r, @g, @b, @a = r, g, b, a
  end
  
  def self.gray g
    new g, g, g
  end
  def self.grawa g, a
    new g, g, g, a
  end
  def self.rgb r, g, b
    new r, g, b
  end
  def self.rgba r, g, b, a
    new r, g, b, a
  end
  def self.hsl h, s, l
    return new 2.55*l, 2.55*l, 2.55*l if s == 0
    h /= 360.0
    s /= 100.0
    l /= 100.0
    t2 = l < 0.5 ? l*(1+s) : l+s-l*s
    t1 = 2*l-t2
    new *([1.0/3, 0, -1.0/3].map do |x|
      t3 = (x+h)%1
      case
      when 6*t3 < 1 ; 100*(t1+(t2-t1)*6*t3)
      when 2*t3 < 1 ; 100*t2
      when 3*t3 < 2 ; 100*(t1+(t2-t1)*6*(2.0/3-t3))
      else          ; 100*t1
      end
    end)
  end
  def self.html s
    s =~ /#((..){3,4})/
    new(*[$1].pack('H*').unpack('C*'))
  end
  def self.rainbow x
    y = x*6.0 % 1
    case x*6.0 % 6
    when 0...1 # 255, 0, 0
      Color.rgb(255, 255*y, 0)
    when 1...2 # 255, 255, 0
      Color.rgb(255-255*y, 255, 0)
    when 2...3 # 0, 255, 0
      Color.rgb(0, 255, 255*y)
    when 3...4 # 0, 255, 255
      Color.rgb(0, 255-255*y, 255)
    when 4...5 # 0, 0, 255
      Color.rgb(255*y, 0, 255)
    when 5...6 # 255, 0, 255
      Color.rgb(255, 0, 255-255*y)
    end
  end
  
  def html alpha=true
    a = alpha ? rgba : rgb
    '#' + a.pack('C*').unpack('H*')[0]
  end
  def rgb
    [@r, @g, @b]
  end
  def rgba
    [@r, @g, @b, @a]
  end
  def hsl
    
  end
  
  # Return random color
  def self.rand
    new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
  # Return random color, with random alpha
  def self.randa
    new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
  
  def == color
    @r == color.r && @g == color.g && @b =color.b && @a == color.a
  end
end
end

# TODO : Add default colors