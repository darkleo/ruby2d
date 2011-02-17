module Ruby2D
class Color
  attr_accessor :r, :g, :b, :a
  private_class_method :new
  def initialize r, g, b, a=255
    @r, @g, @b, @a = r, g, b, a
  end
  
  def self.rgb r, g, b
    new r, g, b
  end
  def self.rgba r, g, b, a
    new r, g, b, a
  end
  def self.html s
    s =~ /#((..){3,4})/
    new(*[$1].pack('H*').unpack('C*'))
  end
  
  def to_html alpha=true
    a = alpha ? to_rgba : to_rgb
    '#' + a.pack('C*').unpack('H*')[0]
  end
  def to_rgb
    [@r, @g, @b]
  end
  def to_rgba
    [@r, @g, @b, @a]
  end
  
  # Return random color
  def self.rand
    new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
  # Return random color, with random alpha
  def self.rand_a
    new Kernel.rand(255), Kernel.rand(255), Kernel.rand(255), Kernel.rand(255)
  end
end
end

# TODO : Add default colors